defmodule WeatherTest do
  use ExUnit.Case, async: false

  setup do
    {:ok, pid} = start_supervised Weather.Worker
    %{pid: pid}
  end

  test "Testing server functionality", %{pid: pid} do

    :sys.statistics(pid, true)
    :sys.trace(pid, true)

    assert Weather.Worker.get_stats(pid) == %{}

    assert Weather.Worker.get_temperature(pid, "Kvikkjokk") =~ 
      ~r/Kvikkjokk: -?\d+\.\d°C/

    assert Weather.Worker.get_stats(pid) == 
      %{"Kvikkjokk" => 1}

    assert Weather.Worker.get_temperature(pid, "Nangijala") == 
      "Nangijala not found"

    assert Weather.Worker.get_stats(pid) == 
      %{"Kvikkjokk" => 1}

    assert Weather.Worker.get_temperature(pid, "Kvikkjokk") =~ 
      ~r/Kvikkjokk: -?\d+\.\d°C/

    assert Weather.Worker.get_stats(pid) == 
      %{"Kvikkjokk" => 2}

    Weather.Worker.reset_stats(pid)
    assert Weather.Worker.get_stats(pid) == %{}

    :sys.no_debug(pid)

    assert Process.alive? pid

    ref = Process.monitor(pid)
    Weather.Worker.stop(pid)

    is_dead = receive do
      {:DOWN, ^ref, _, _, _} -> true
    after
      5_000 -> false
    end
    assert is_dead

  end

end
