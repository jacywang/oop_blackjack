require "pry"
class Deck
  SUITS = ["D", "H", "S", "C"]
  CARDS = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  ONE_DECK = SUITS.product(CARDS)
  attr_accessor :deck

  def initialize
    @deck = []
    [1, 2, 3].sample.times do 
      @deck += ONE_DECK
    end
  end

  def shuffle
    deck.shuffle!
  end

  def hand_card
    deck.pop
  end

  def size
    deck.size
  end
end

module Hand
  BLACKJACK_AMOUNT = 21

  def get_card(card)
    mycards << card
  end

  def calculate_total
    arr = mycards.map { |e| e[1] }

    total = 0

    arr.each do |value|
      if value == "A"
        total += 11
      elsif value.to_i == 0
        total += 10
      else
        total += value.to_i
      end
    end

    arr.count("A").times do
      total -= 10 if total > BLACKJACK_AMOUNT
    end

    total
  end

  def blackjack?
    if calculate_total == BLACKJACK_AMOUNT
      puts "#{name} hit blackjack! #{name} won!"
      Game.new.play_again
    else
      false
    end
  end

  def busted?
    if calculate_total > BLACKJACK_AMOUNT
      puts "#{name} busted and lost!"
      Game.new.play_again
    else
      false
    end
  end

  def display_cards
    puts "#{name} has cards #{mycards} for a total of #{calculate_total}."
  end
end

class Player
  include Hand
  attr_accessor :name, :mycards

  def initialize(n)
    @name = n
    @mycards = []
  end

  def take_action(deck)
    while calculate_total < BLACKJACK_AMOUNT
      puts "What would you like to do? 1) hit 2) stay"
      hit_or_stay = gets.chomp

      if !["1", "2"].include?(hit_or_stay)
        puts "Error: you must enter 1 or 2."
        next
      end

      if hit_or_stay == "2"
        puts "#{name} chose to stay."
        break
      end

      puts "#{name} chose to hit."
      new_card = deck.hand_card
      puts "#{name} got a new card #{new_card}."
      get_card(new_card)
      display_cards
      blackjack?
      busted?
    end
  end
end

class Dealer
  include Hand
  attr_accessor :name, :mycards

  def initialize
    @name = "Dealer"
    @mycards = []
  end

  DEALER_STAY_MIN = 17

  def display_cards_before_player_stay
    puts "#{name} has cards #{[["*", "*"], mycards[1]]}."
  end

  def take_action(deck)
    while calculate_total < DEALER_STAY_MIN
      new_card = deck.hand_card
      puts "#{name} got a new card #{new_card}."
      get_card(new_card)
      display_cards
      blackjack?
      busted?
    end
  end
end

class Game
  attr_accessor :deck, :player, :dealer

  def initialize
    @deck = Deck.new
    @player = Player.new("Jacy")
    @dealer = Dealer.new
  end

  def winner_is(player, dealer)
    puts "----Show Result----"
    dealer.display_cards
    player.display_cards
    if player.calculate_total == dealer.calculate_total
      puts "It's a tie!"
    elsif player.calculate_total > dealer.calculate_total
      puts "#{player.name} won!"
    else
      puts "#{dealer.name} won!"
    end
  end

  def set_player_name
    puts "What's your name?"
    player.name = gets.chomp
  end

  def play
    puts "----Welcome to Blackjack!----"
    deck.shuffle
    2.times do
      player.get_card(deck.hand_card)
      dealer.get_card(deck.hand_card)
    end
    dealer.display_cards_before_player_stay
    player.display_cards
    player.blackjack?
    puts "Now it's #{player.name}'s turn!"
    player.take_action(deck)
    puts "Now it's #{dealer.name}'s turn!"
    dealer.display_cards
    player.display_cards
    dealer.blackjack?
    dealer.take_action(deck)
    winner_is(player, dealer)
    play_again
  end

  def play_again
    begin 
      puts "----Play again? Y/N----"
      choice = gets.chomp.upcase
    end until ["Y", "N"].include?(choice)
    if choice == "Y"
      Game.new.play
    else
      exit
    end
  end
end

Game.new.play
 

