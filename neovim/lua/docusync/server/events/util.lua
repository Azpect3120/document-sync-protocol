-- This file contains utility functions that are used in the server implementation

return {
  --- Generate a random identifier for a client that did not provide one.
  --- @return string 
  generete_identifer = function()
    return "Client_" .. math.random(10000000, 99999999)
  end
}
