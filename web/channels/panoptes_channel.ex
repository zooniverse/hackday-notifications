defmodule Notifications.PanoptesChannel do
  use Phoenix.Channel

  def join("panoptes", _message, socket) do
    {:ok, socket}
  end
end
