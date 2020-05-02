# frozen_string_literal: true

require_relative 'game_error'

module Engine
  class Route
    attr_reader :connections, :phase, :train

    def initialize(phase, train)
      @connections = []
      @start = nil
      @phase = phase
      @train = train
    end

    def reset!
      @connections.clear
      @start = nil
    end

    def add_hex(hex)
      if @connections.any?
        @connections[0].connections + @connections[-1].connections.each do |connection|
          if connection.hexes.include?(hex)
            @connections << connection
            return
          end
        end
      elsif @start
        connection = @start.all_connections.find { |c| c.hexes.include?(hex) }
        @connections << connection if connection
      else
        @start = hex
      end
      puts "clicked hexes #{@hexes}"
      puts connections.inspect
    end

    def paths_for(paths)
      @connections.flat_map(&:paths) & paths
    end

    def stops
      @connections.flat_map(&:stops).uniq
    end

    def hexes
      @connections.flat_map(&:hexes).uniq
    end

    def revenue
      stops_ = stops
      raise GameError, 'Route must have at least 2 stops' if stops_.size < 2
      raise GameError, "#{stops_.size} is too many stops for #{@train.distance} train" if @train.distance < stops_.size

      stops_.map { |stop| stop.route_revenue(@phase, @train) }.sum
    end
  end
end
