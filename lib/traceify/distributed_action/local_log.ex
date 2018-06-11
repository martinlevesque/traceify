defmodule Traceify.DistributedAction.LocalLog do

  alias Traceify.DistributedAction.ActionUtil

  defp init_db(write_to_dir) do
    ctbl = """
      CREATE TABLE IF NOT EXISTS logs (
        id integer PRIMARY KEY AUTOINCREMENT,
        level VARCHAR(15) NOT NULL,
        content TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    """

    Sqlitex.with_db("#{write_to_dir}/db.sqlite3", fn(db) ->
      Sqlitex.query(db, ctbl)
      Sqlitex.query(db, "CREATE INDEX level_ind ON logs(level)")
      Sqlitex.query(db, "CREATE INDEX content_ind ON logs(content)")
    end)
  end

  def log(service, level, content) do
    write_to_dir = ActionUtil.prepare_log_dir(service)
    init_db(write_to_dir)

    Sqlitex.with_db("#{write_to_dir}/db.sqlite3", fn(db) ->
      Sqlitex.query!(
        db,
        "INSERT INTO logs (level, content) VALUES ($1, $2)",
        bind: [level, inspect(content)]
      )
    end)

    "success"
  end

end