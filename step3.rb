class Card
  attr_reader :value, :suit

  def initialize(value, suit)
    @value = value
    @suit = suit
  end

  def to_s
    "#{suit_to_str}の#{value_to_str}"
  end

  def value_to_str
    case value
    when 1 then "A"
    when 11 then "J"
    when 12 then "Q"
    when 13 then "K"
    else value.to_s
    end
  end
end

class Deck
  attr_reader :cards

  def initialize
    @cards = []
    [:スペード, :ハート, :ダイヤ, :クラブ].each do |suit|
      (1..13).each do |value|
        @cards << Card.new(value, suit)
      end
    end
    @cards.shuffle!
  end

  def draw
    cards.pop
  end
end

class Hand
  attr_reader :cards

  def initialize
    @cards = []
  end

  def add_card(card)
    cards << card
  end

  def score
    sum = 0
    num_aces = 0

    cards.each do |card|
      if card.value == 1
        num_aces += 1
        sum += 11
      elsif card.value >= 10
        sum += 10
      else
        sum += card.value
      end
    end

    while sum > 21 && num_aces > 0
      sum -= 10
      num_aces -= 1
    end

    sum
  end
end

class Player
  attr_reader :hand

  def initialize
    @hand = Hand.new
  end

  def hit(deck)
    hand.add_card(deck.draw)
  end

  def busted?
    hand.score > 21
  end
end

class Dealer < Player
  def face_up_card
    hand.cards.first
  end
end

class Blackjack
  attr_reader :deck, :player, :dealer

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def play
    puts "ブラックジャックを開始します。"

    2.times do
      player.hit(deck)
      dealer.hit(deck)
    end

    display_initial_hands

    while !player.busted?
      puts "あなたの現在の得点は#{player.hand.score}です。カードを引きますか？（Y/N）"
      input = gets.chomp.upcase
      if input == 'Y'
        player.hit(deck)
        puts "あなたの引いたカードは#{player.hand.cards.last}です。"
      elsif input == 'N'
        break
      end
    end

    if player.busted?
      puts "あなたの得点は#{player.hand.score}です。"
      puts "あなたの負けです。"
else
puts "ディーラーの引いた2枚目のカードは#{dealer.hand.cards[1]}でした。"
puts "ディーラーの現在の得点は#{dealer.hand.score}です。"
while dealer.hand.score < 17
  dealer.hit(deck)
  puts "ディーラーの引いたカードは#{dealer.hand.cards.last}です。"
end

puts "あなたの得点は#{player.hand.score}です。"
puts "ディーラーの得点は#{dealer.hand.score}です。"

if dealer.busted?
  puts "あなたの勝ちです！"
elsif player.hand.score > dealer.hand.score
  puts "あなたの勝ちです！"
elsif player.hand.score < dealer.hand.score
  puts "あなたの負けです。"
else
  puts "引き分けです。"
end
end

puts "ブラックジャックを終了します。"
end

private

def display_initial_hands
puts "あなたの引いたカードは#{player.hand.cards[0]}です。"
puts "あなたの引いたカードは#{player.hand.cards[1]}です。"
puts "ディーラーの引いたカードは#{dealer.face_up_card}です。"
puts "ディーラーの引いた2枚目のカードはわかりません。"
end
end
# Card, Deck, Hand, Player, Dealer クラスは前のコードと同じなので省略します。

class NPC < Player
  def play(deck)
    while hand.score < 17
      hit(deck)
    end
  end
end

class Blackjack
  attr_reader :deck, :player, :dealer, :npcs

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
    @npcs = []
  end

  def add_npcs(num_npcs)
    num_npcs.times do
      @npcs << NPC.new
    end
  end

  def play
    puts "ブラックジャックを開始します。"
    puts "0〜2の範囲でNPCの人数を入力してください。"
    num_npcs = gets.chomp.to_i
    add_npcs(num_npcs)

    2.times do
      player.hit(deck)
      dealer.hit(deck)
      npcs.each { |npc| npc.hit(deck) }
    end

    display_initial_hands

    # プレイヤーのターン
    while !player.busted?
      puts "あなたの現在の得点は#{player.hand.score}です。カードを引きますか？（Y/N）"
      input = gets.chomp.upcase
      if input == 'Y'
        player.hit(deck)
        puts "あなたの引いたカードは#{player.hand.cards.last}です。"
      elsif input == 'N'
        break
      end
    end

    # NPCのターン
    npcs.each_with_index do |npc, index|
      npc.play(deck)
      puts "NPC #{index + 1}の得点は#{npc.hand.score}です。"
    end

    # ディーラーのターン
    puts "ディーラーの引いた2枚目のカードは#{dealer.hand.cards[1]}でした。"
    puts "ディーラーの現在の得点は#{dealer.hand.score}です。"

    while dealer.hand.score < 17
      dealer.hit(deck)
      puts "ディーラーの引いたカードは#{dealer.hand.cards.last}です。"
    end

    # 勝敗判定
    puts "あなたの得点は#{player.hand.score}です。"
    npcs.each_with_index do |npc, index|
      puts "NPC #{index + 1}の得点は#{npc.hand.score}です。"
    end
    puts "ディーラーの得点は#{dealer.hand.score}です。"

    judge(player, dealer)
    npcs.each_with_index do |npc, index|
      puts "NPC #{index + 1}:"
      judge(npc, dealer)
    end

    puts "ブラックジャックを終了します。"
  end

  private

  def display_initial_hands
    puts "あなたの引いたカードは#{player.hand.cards[0]}です。"
    puts "あなたの引いたカードは#{player.hand.cards[1]}です。"
    puts "ディーラーの引いたカードは#{dealer.face_up_card}です。"
    puts "ディーラーの引いた2枚目のカードはわかりません。"
    npcs.each_with_index do |npc, index|
      puts "NPC #{index + 1}の引いたカードは#{npc.hand.cards[0]}と#{npc.hand.cards[1]}です。"
    end
  end


  def judge(player, dealer)
    if player.busted?
      puts "あなたの負けです。"
    elsif dealer.busted? || player.hand.score > dealer.hand.score
      puts "あなたの勝ちです！"
    elsif player.hand.score < dealer.hand.score
      puts "あなたの負けです。"
    else
      puts "引き分けです。"
    end
  end
end

game = Blackjack.new
game.play
