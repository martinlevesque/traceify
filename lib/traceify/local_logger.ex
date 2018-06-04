defmodule Traceify.Instances.LocalLogger do

  def prepare_log_dir(service, t) do
    db_root_location = service.storage_area.root_path

    write_to_dir = "#{db_root_location}/#{service.site_name}"
    File.mkdir_p!(write_to_dir)

    write_to_dir
  end

  def log(conn, service, level, content) do
    IO.puts "headers = #{conn.get_headers}"
    t = DateTime.utc_now()
    t_date = DateTime.to_date(t)
    write_to_dir = prepare_log_dir(service, t)

    line_2_log = "#{DateTime.to_string(t)} - [#{level}] - #{inspect(content)}\n"

    File.write!("#{write_to_dir}/#{Date.to_string(t_date)}.log", line_2_log, [:append])

    "success"
  end

end
