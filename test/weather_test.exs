defmodule WeatherTest do
  use ExUnit.Case
  doctest Weather

  test "Returns temperature for real location." do
    assert Weather.Worker.temperature_of("Kvikkjokk") =~ 
      ~r/Kvikkjokk: -?\d+\.\d°C/
  end

  test "Returns 'not found' for imaginary location." do
    assert Weather.Worker.temperature_of("Nangijala") == 
      "Nangijala not found"
  end

end
