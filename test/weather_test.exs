defmodule WeatherTest do
  use ExUnit.Case, async: false

  setup_all do
    {:ok, pid} = start_supervised Weather.Worker
    %{pid: pid}
  end

  test "Stats is empty right after server start.", %{pid: pid} do
    assert Weather.Worker.get_stats(pid) == %{}
  end

  test "Returns temperature for real location.", %{pid: pid} do
    assert Weather.Worker.get_temperature(pid, "Kvikkjokk") =~ 
      ~r/Kvikkjokk: -?\d+\.\d°C/
  end

  test "Stats updated after first call.", %{pid: pid} do
    assert Weather.Worker.get_stats(pid) == 
      %{"Kvikkjokk" => 1}
  end

  test "Returns 'not found' for imaginary location.", %{pid: pid} do
    assert Weather.Worker.get_temperature(pid, "Nangijala") == 
      "Nangijala not found"
  end

end
