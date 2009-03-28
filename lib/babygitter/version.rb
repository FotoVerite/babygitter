require 'net/ssh/version'

module Babygitter

  # Describes the current version of Capistrano.
  class Version < Net::SSH::Version
    MAJOR = 0
    MINOR = 8
    TINY  = 0

    # The current version, as a Version instance
    CURRENT = new(MAJOR, MINOR, TINY)

    # The current version, as a String instance
    STRING  = "Babygitter version " + CURRENT.to_s
  end

end