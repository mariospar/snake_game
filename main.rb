require 'ruby2d'

# These are ruby2d environment variables
set title: "Snake Game", background: "navy", fps_cap: 8

GRID_SIZE = 20 # Square side pixels

# The default window is 680px by 480px
GRID_WIDTH = Window.width / GRID_SIZE
GRID_HEIGHT = Window.height / GRID_SIZE

TEXT_COLOR = "white"
SNAKE_COLOR = "white"
FOOD_COLOR = "red"

class Snake

  def initialize
    @positions = [[2,0], [2,1], [2,2], [2,3]] # Could be random
    @growing = false
    @direction = "down"
  end

  def draw
    @positions.each do |position|
      Square.new(x: position[0] * GRID_SIZE, y: position[1] * GRID_SIZE, size: GRID_SIZE - 1, color: SNAKE_COLOR) 
    end
  end

  def move
    if !@growing
      # This creates the illusion of movement since it pops the tail of the snake
      # but instanteously it appends a square at the head. If the snake ate the food
      # then since it needs to grow, don't pop the tail square.
      @positions.shift
    end

    case @direction
    when "down"
      @positions.push(coords(x, y + 1))
    when "left"
      @positions.push(coords(x - 1, y))
    when "up"
      @positions.push(coords(x, y - 1))
    when "right"
      @positions.push(coords(x + 1, y))
    end
    @growing = false
  end

  def grow
    @growing = true #This is a state property for the move method
  end

  def bite_itself?
    @positions.uniq.length != @positions.length
  end

  def can_change_direction?(new_direction)
    case @direction
    when "up" then new_direction != "down"
    when "down" then new_direction != "up"
    when "right" then new_direction != "left"
    when "left" then new_direction != "right"
    end
  end

  # Property getters
  def x
    head[0]
  end
  
  def y
    head[1]
  end

  # Property setters
  def direction=(direction)
    @direction = direction
  end

  # Private methods
  private

  def coords(x, y)
    [x % GRID_WIDTH, y % GRID_HEIGHT]
  end
  
  def head
    @positions.last
  end
end

class Game

  def initialize
    @food_x, @food_y = random_coords
    @score = 0
    @finished = false
  end

  def draw
    unless finished?
      Square.new(x: @food_x * GRID_SIZE, y: @food_y * GRID_SIZE, size: GRID_SIZE, color: FOOD_COLOR)
    end
    Text.new(text_message, color: TEXT_COLOR, x: 10, y: 10, size: 24)
  end

  def record_hit
    @score += 1
    @food_x, @food_y = random_coords
  end

  def play_eat_audio
    sound = Sound.new("eat_sound.wav")
    sound.play
  end

  def game_over
    if not finished?
      sound = Music.new("game_over.wav")
      sound.play
      sleep(2)
    end
    @finished = true
  end

  def finished?
    @finished
  end

  def snake_ate_food?(x, y)
    @food_x == x && @food_y == y
  end

  # Private methods
  private

  def random_coords
    [rand(GRID_WIDTH), rand(GRID_HEIGHT)]
  end

  def text_message
    if finished?
      "Game over, your score was #{@score}. Press R to restart."
    else
      "Score: #{@score}"
    end
  end
end

snake = Snake.new
game = Game.new

music = Music.new("music.mp3")
music.loop = true
music.volume = 50
music.play

update do
  clear

  unless game.finished?
    snake.move
  end

  snake.draw
  game.draw

  if game.snake_ate_food?(snake.x, snake.y)
    game.record_hit
    snake.grow
    game.play_eat_audio
  end

  if snake.bite_itself?
    game.game_over
  end
end

on :key_down do |event|
  if ["up", "down", "left", "right"].include?(event.key)
    if snake.can_change_direction?(event.key)
      snake.direction = event.key
    end
  elsif event.key == "r" && game.finished?
    snake = Snake.new
    game = Game.new
    music = Music.new("music.mp3")
    music.loop = true
    music.volume = 50
    music.play  
  elsif event.key == "escape"
    close
  end
end

show