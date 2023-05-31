defmodule TimexWeb.StopwatchManager do
  use GenServer

  def init(ui) do
    :gproc.reg({:p, :l, :ui_event})
    GenServer.cast(ui, {:set_time_display, ~T[00:00:00.00] |> Time.truncate(:millisecond) |> Time.to_string |> String.slice(3..-1)})
    {:ok, %{ui_pid: ui, count: ~T[00:00:00.00], st1: Working, st2: Paused, mode: Time}}
  end

  def handle_info(:"top-left", %{st1: Working, mode: mode, ui_pid: ui, count: count} = state) do
    IO.puts("IN .... abc")
    mode =
      if mode == Time do
        GenServer.cast(ui, {:set_time_display, count |> Time.truncate(:millisecond) |> Time.to_string |> String.slice(3..-2)})

        SWatch
      else
        Time
      end
    {:noreply, %{state | mode: mode}}
  end
  #Para reiniciar el stopwatch
  def handle_info(:"bottom-left", %{ui_pid: ui, st1: Working} = state) do
    GenServer.cast(ui, {:set_time_display, ~T[00:00:00.00] |> Time.truncate(:millisecond) |> Time.to_string |> String.slice(3..-1)})
    {:noreply, %{state | count: ~T[00:00:00.00]}}
  end
  #Iniciar stopwatch
  def handle_info(:"bottom-right", %{st2: Paused, mode: SWatch} = state) do
    Process.send_after(self(), Counting_to_Counting, 10)
    {:noreply, %{state | st2: Counting}}
  end

  def handle_info(:"bottom-right", %{st2: Counting, mode: SWatch} = state) do
    {:noreply, %{state | st2: Paused}}
  end

  def handle_info(Counting_to_Counting, %{st2: Counting, count: count, ui_pid: ui, mode: mode} = state) do
    Process.send_after(self(), Counting_to_Counting, 10)
    count = Time.add(count, 10, :millisecond)
    if mode == SWatch do
      GenServer.cast(ui, {:set_time_display, count |> Time.truncate(:millisecond) |> Time.to_string |> String.slice(3..-2)})
    end
    {:noreply, %{state | st2: Counting, count: count}}
  end

  def handle_info(event, state) do
    IO.inspect(event)
   {:noreply, state}
  end
end
