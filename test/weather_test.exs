defmodule WeatherTest do
  use ExUnit.Case, async: false

  setup do
    {:ok, pid} = start_supervised Weather.Worker
    %{pid: pid}
  end

  test "Testing server functionality", %{pid: pid} do

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

  end

end
