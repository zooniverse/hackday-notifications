defmodule Notifications.Streamer do
  alias ExAws.Kinesis
  use GenServer

  def start_link(stream_name) do
    us = self()
    reader = spawn fn -> reader_fun(us, stream_name) end

    Process.link(reader)

    GenServer.start_link(__MODULE__, :ok, [])
  end

  def reader_fun(us, stream_name) do
    stream_name
    |> get_shards
    |> Enum.map(&Kinesis.get_shard_iterator(stream_name, &1["ShardId"], "LATEST"))
    |> Enum.map(&get_records(&1, 10))
  end

  defp get_shards(name) do
    case Kinesis.describe_stream(name) do
      {:ok, %{"StreamDescription" => %{"Shards" => shards}}} -> shards
      error -> raise inspect(error)
    end
  end

  def get_records({:ok, %{"ShardIterator" => iterator}}, wait_time) do
    iterator
    |> Kinesis.stream_records([], fn
      []  -> :timer.sleep(wait_time * 1000); []
      val -> val
    end)
    |> Stream.map(&parse/1)
    |> Stream.map(&broadcast/1)
    |> Stream.run
  end

  defp parse(msg) do
    try do
      Poison.Parser.parse! msg["Data"]
    rescue
      _ -> %{source: "errored", type: "errored"}
    end
  end

  defp broadcast(msg) do
    try do
      Notifications.Endpoint.broadcast! msg["source"], msg["type"], msg
    rescue
      _ -> IO.inspect("ERROR")
    end
  end
end
