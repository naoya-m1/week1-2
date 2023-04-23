class Card
  SUITS = %w[ハート ダイヤ クローバー スペード].freeze
  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze

  attr_reader :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def value
    case rank
    when 'A'
      11
    when 'K', 'Q', 'J'
      10
    else
      rank.to_i
    end
  end

  def to_s
    "#{suit}の#{rank}"
  end
end

class Deck
  def initialize
    @cards = Card::SUITS.product(Card::RANKS).map { |suit, rank| Card.new(rank, suit) }.shuffle
  end

  def deal
    @cards.pop
  end
end

class Hand
  attr_accessor :cards

  def initialize(cards = [])
    @cards = cards
  end

  def score
    total = cards.map(&:value).sum
    cards.select { |card| card.rank == 'A' }.count.times do
      break if total <= 21

      total -= 10
    end
    total
  end

  def busted?
    score > 21
  end
end

class Player
  attr_accessor :hands, :surrendered

  def initialize
    @hands = [Hand.new]
    @surrendered = false
  end

  def hit(deck)
    hands.each { |hand| hand.cards << deck.deal }
  end

  def double_down(deck)
    hands.each { |hand| hand.cards << deck.deal }
    @surrendered = true # ダブルダウン後はサレンダー不可
  end

  def surrender
    @surrendered = true
  end
end

class Dealer
  attr_accessor :hand

  def initialize
    @hand = Hand.new
  end

  def hit(deck)
    hand.cards << deck.deal
  end

  def split
    return unless hands.length == 1 && hands[0].cards.length == 2 && hands[0].cards[0].rank == hands[0].cards[1].rank

    hands << Hand.new([hands[0].cards.pop])
  end
end

class NPC < Player
end

class Blackjack
  attr_accessor :player, :dealer, :npcs

  def initialize
    @player = Player.new
    @dealer = Dealer.new
    @npcs = []
    @deck = Deck.new
  end

  def setup_game
    2.times do
      @player.hit(@deck)
      @dealer.hit(@deck)
      @npcs.each { |npc| npc.hit(@deck) }
    end
  end

  def display_initial_hands
    puts "あなたの手札: #{player.hands[0].cards.map(&:to_s).join(', ')}"
    puts "ディーラーの手札: #{dealer.hand.cards[0]}"
    @npcs.each_with_index do |npc, index|
      puts "NPC #{index + 1} の手札: #{npc.hands[0].cards.map(&:to_s).join(', ')}"
    end
  end

  def add_npcs(num_npcs)
    num_npcs.times { @npcs << NPC.new }
  end

  def play
    puts 'ブラックジャックを開始します。'
    puts 'NPCの人数を入力してください (0 ～ 2):'
    num_npcs = gets.chomp.to_i
    add_npcs(num_npcs)
    setup_game

    # 初期手札の表示
    display_initial_hands


    # プレイヤーのターン
    player_turn

    # NPCのターン
    npc_turns

    # ディーラーのターン
    dealer_turn

    # 勝敗判定

    player.hands.each_with_index do |hand, _hand_index|
      judge(player, dealer, hand)
    end
  end

  def player_turn
    player.hands.each_with_index do |hand, _hand_index|
      until hand.busted? || player.surrendered
        puts "あなたの現在の得点は#{hand.score}です。"
        puts 'カードを引く (H), 引かない (S), ダブルダウン (D), サレンダー (R), スプリット (P)'
        action = gets.chomp.upcase
        case action
        when 'H'
          hand.cards << @deck.deal
        when 'D'
          player.double_down(@deck)
          break
        when 'S'
          break
        when 'R'
          player.surrender
          break
        when 'P'
          player.split
        end
      end
    end
  end

  def dealer_turn
    dealer.hit(@deck) while dealer.hand.score < 17
  end

  def judge(player, dealer, hand)
    if player.surrendered
      puts 'サレンダーしました。あなたの負けです。'
    elsif hand.busted?
      puts "あなたの得点は#{hand.score}です。"
      puts "ディーラーの得点は#{dealer.hand.score}です。"
      puts 'あなたの負けです。'
    elsif dealer.hand.busted?
      puts "あなたの得点は#{hand.score}です。"
      puts "ディーラーの得点は#{dealer.hand.score}です。"
      puts 'あなたの勝ちです！'
    elsif hand.score > dealer.hand.score
      puts "あなたの得点は#{hand.score}です。"
      puts "ディーラーの得点は#{dealer.hand.score}です。"
      puts 'あなたの勝ちです！'
    elsif hand.score < dealer.hand.score
      puts "あなたの得点は#{hand.score}です。"
      puts "ディーラーの得点は#{dealer.hand.score}です。"
      puts 'あなたの負けです。'
    else
      puts "あなたの得点は#{hand.score}です。"
      puts "ディーラーの得点は#{dealer.hand.score}です。"
      puts '引き分けです。'
    end
  end

  def npc_turns
    @npcs.each_with_index do |npc, index|
      puts "NPC #{index + 1} のターン:"
      npc_turn(npc)
      puts "NPC #{index + 1} の得点: #{npc.hands[0].score}"
    end
  end

  def npc_turn(npc)
    npc.hit(@deck) while npc.hands[0].score < 17
  end
end

game = Blackjack.new
game.play
