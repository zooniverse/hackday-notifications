defmodule Notifications.EventController do
  use Notifications.Web, :controller

  def create(conn, %{"channel" => channel, "event" => event, "message" => message}) do
    Notifications.Endpoint.broadcast! channel, event, message
    conn |> send_resp(201, "")
  end
end
