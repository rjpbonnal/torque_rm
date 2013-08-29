module TORQUE
  module Qdel

    def self.rm(id)
      TORQUE.server.qdel(id)
    end

    def self.rm_all
      TORQUE.server.qdel("all")
    end

  end # Qdel
end # TORQUE
