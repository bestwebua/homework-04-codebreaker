require 'colorize'
require 'erb'

module Codebreaker
  class Console
    include Message
    include Motivation
    include UserScore
    include Storage

    DEMO = Game.new('Demo User', 5, 2, :middle, :en)
    HINT = '-h'.freeze
    YES = 'y'.freeze
    EMPTY_INPUT = ''.freeze

    attr_reader :game, :scores

    def initialize(game = DEMO)
      @locale = Localization.new(:console)
      load_console(game)
      start_game if game == DEMO
    end

    def start_game
      puts message['alerts']['welcome'].colorize(background: :blue)
      puts message['alerts']['hint_info']
      submit_answer
    end

    def erase_scores
      print message['alerts']['erase_scores']
      erase_game_data if input_selector
      exit_console
    end

    private_constant :DEMO

    private

    def load_console(game)
      raise ArgumentError, message['errors']['wrong_object'] unless game.is_a?(Game)
      @game = game
      @locale.lang = game.configuration.lang
      @game_config_snapshot = game.configuration.clone
      apply_external_path
      @scores = load_game_data
    end

    def submit_answer
      process(user_interaction)
    end

    def show_hint
      puts begin
        "#{message['alerts']['hint']}: #{game.hint.to_s.green}"
      rescue => error
        error.to_s.red
      end
    end

    def user_interaction(input = EMPTY_INPUT)
      return if game.attempts.zero?
      status, step = false, 0
      until status
        begin
          game.guess_valid?(input)
          status = true
        rescue => error
          puts error.to_s.red unless step.zero? || input == HINT
          puts "#{message['alerts']['guess']}:"
          input = gets.chomp
          step += 1
          show_hint if input == HINT
        end
      end
      input
    end

    def process(input)
      begin
        puts game.to_guess(input)
        puts motivation_message(message['alerts']['motivation'])
      rescue => error
        puts error
        finish_game
      end
      game.won? ? finish_game : submit_answer
    end

    def summary
      game.won? ? message['alerts']['won'].green : message['alerts']['lose'].red
    end

    def finish_game
      puts ERB.new(message['info']['results']).result(binding)
      save_game
      new_game
    end

    def input_selector
      input = EMPTY_INPUT
      until %w[y n].include?(input)
        print " (y/n) #{message['alerts']['yes_or_no']}:"
        input = gets.chomp
      end
      input == YES
    end

    def save_game
      print message['alerts']['save_game']
      save_game_data if input_selector
    end

    def save_game_data
      save_user_score
      prepare_storage_dir
      save_to_yml
      puts message['info']['successfully_saved'].green
    end

    def new_game
      print message['alerts']['new_game']
      if input_selector
        load_new_game
        start_game
      else
        puts message['alerts']['shutdown']
        exit_console
      end
    end

    def exit_console
      exit
    end

    def load_new_game
      @game = Game.new do |config|
        @game_config_snapshot.each_pair do |key, value|
          config[key] = value
        end
      end
    end

    def erase_game_data
      begin
        erase_data_file
        scores.clear
        puts message['info']['successfully_erased'].green
      rescue
        puts message['errors']['file_not_found'].red
      end
    end
  end
end
