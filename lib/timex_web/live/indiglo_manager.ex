defmodule TimexWeb.IndigloManager do
  use GenServer

  def init(ui) do
    :gproc.reg({:p, :l, :ui_event})
    {:ok, %{ui_pid: ui, st: IndigloOff}}
  end

  # IndigloOff -- top-right/set_indiglo() --> IndigloOn
  def handle_info(:"top-right", %{st: IndigloOff, ui_pid: ui} = state) do
    GenServer.cast(ui, :set_indiglo)
    {:noreply, state |> Map.put(:st, IndigloOn) }
  end

  # IndigloOn -- top-right(released) --> Waiting
  def handle_info(:"top-right", %{st: IndigloOn} = state) do
    Process.send_after(self(), Waiting_IndigloOff, 2000)
    {:noreply, state |> Map.put(:st, Waiting)}
  end

  # Waiting -- after 2s --> IndigloOff
  def handle_info(Waiting_IndigloOff, %{st: Waiting, ui_pid: ui} = state) do
    GenServer.cast(ui, :unset_indiglo)
    {:noreply, state |> Map.put(:st, IndigloOff)}
  end

  def handle_info(_event, state), do: {:noreply, state}
end
