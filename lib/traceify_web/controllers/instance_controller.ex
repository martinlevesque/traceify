defmodule TraceifyWeb.InstanceController do
  use TraceifyWeb, :controller

  alias Traceify.DistributedAction
  import Logger

  action_fallback TraceifyWeb.FallbackController

  def index(conn, _params) do
    render(conn, "index.json")
  end

  defp handle_error(conn, code, msg) do
    Logger.error("handle error: #{inspect msg}")

    conn
    |> put_status(:internal_server_error)
    |> render(TraceifyWeb.ErrorView, "#{code}.json", %{msg: msg})
  end

  defp distributed_action(conn, action, sitename, levels, params) do
    try do
      result = DistributedAction.action(conn, action, sitename, levels, params)

      cond do
        ! is_nil(result) -> render(conn, "#{action}.json", %{result: result})
        true -> handle_error(conn, 500, result)
      end

    rescue
      e in File.Error -> handle_error(conn, 500, File.Error.message(e))
      e in RuntimeError -> handle_error(conn, 500, RuntimeError.message(e))
      e in _ -> handle_error(conn, 500, e)
    end
  end

  def log(conn, %{"sitename" => sitename, "level" => level}) do
    distributed_action(conn, "log", sitename, [level], conn.body_params)
  end

  def search(conn, %{"sitename" => sitename}) do
    levels = if conn.body_params["levels"], do: conn.body_params["levels"], else: []

    distributed_action(conn, "search", sitename, levels, conn.body_params)
  end

  def stats(conn, %{"sitename" => sitename}) do
    distributed_action(conn, "stats", sitename, [], %{})
  end

end
