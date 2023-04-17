require 'app/tick.rb'

class PongGame
  attr_gtk

  def tick
    state ||= args.state
    input ||= args.inputs
    graphics ||= args.outputs

    if state.gameObjects.nil?
      createGameObjects(state, graphics)
      state.gameObjects ||= true
    end

    if !state.gameOver
      paddleMovements(input, state)
      ballMovement(state)
      ballCollisions(state)
      render(graphics, state)
    end

    if state.gameOver
      graphics.sprites << {x:0, y:0, w:1280, h:720, path: :pixel, r: 0, g: 0, b: 0}
      offset = args.gtk.calcstringbox("Game Over", 40)
      graphics.labels << {x:640 - offset[0]/2, y:360 + offset[1]/2, text: "Game Over", size_enum: 40, r: 255, g: 255, b: 255}
      offset = args.gtk.calcstringbox("Press Enter to Play Again", 14)
      graphics.labels << {x:640 - offset[0]/2, y:300 - offset[1]/2, text: "Press Enter to Play Again", size_enum: 14, r: 255, g: 255, b: 255}
      if input.keyboard.key_down.enter
        state.gameObjects = nil
      end
    end
  end

  def getPaddle(x, y, w, h, color)
    {
      x: x,
      y: y,
      w: w,
      h: h,
      path: :pixel,
      r: color[0],
      g: color[1],
      b: color[2]
    }
  end

  def getBall (x, y, w, h, color)
    {
      x: x,
      y: y,
      w: w,
      h: h,
      path: :pixel,
      r: color[0],
      g: color[1],
      b: color[2],
      xSpeed: 5,
      ySpeed: 5
    }
  end

  def createGameObjects(state, graphics)
    state.paddles = {
      one: getPaddle(50, 360, 10, 100, [255, 255, 255]),
      two: getPaddle(1230, 360, 10, 100, [255, 255, 255])
    }
    state.ball = getBall(640, 360, 10, 10, [255, 255, 255])
    state.gameOver = false
  end

  def paddleMovements(input, state)
    if input.keyboard.key_held.up
      state.paddles[:two][:y] += 5
    end
    if input.keyboard.key_held.down
      state.paddles[:two][:y] -= 5
    end
    if input.keyboard.key_held.w
      state.paddles[:one][:y] += 5
    end
    if input.keyboard.key_held.s
      state.paddles[:one][:y] -= 5
    end
  end

  def ballMovement(state)
    state.ball[:x] += state.ball[:xSpeed]
    state.ball[:y] += state.ball[:ySpeed]
  end

  def ballCollisions(state)
    ballCollideswithTopAndBottom(state)
    ballCollidesWithPaddles(state)
    ballCollidesWithSides(state)
  end

  def ballCollideswithTopAndBottom(state)
    if state.ball[:y] < 0
      state.ball[:ySpeed] = -state.ball[:ySpeed]
    end
    if state.ball[:y] > 720
      state.ball[:ySpeed] = -state.ball[:ySpeed]
    end
  end

  def ballCollidesWithPaddles(state)
    # collide with paddle one
    if state.ball[:x] < state.paddles[:one][:x] + state.paddles[:one][:w] &&
      state.ball[:x] + state.ball[:w] > state.paddles[:one][:x] &&
      state.ball[:y] < state.paddles[:one][:y] + state.paddles[:one][:h] &&
      state.ball[:y] + state.ball[:h] > state.paddles[:one][:y]

      state.ball[:xSpeed] = -state.ball[:xSpeed]
    end

    # collide with paddle two
    if state.ball[:x] < state.paddles[:two][:x] + state.paddles[:two][:w] &&
      state.ball[:x] + state.ball[:w] > state.paddles[:two][:x] &&
      state.ball[:y] < state.paddles[:two][:y] + state.paddles[:two][:h] &&
      state.ball[:y] + state.ball[:h] > state.paddles[:two][:y]

      state.ball[:xSpeed] = -state.ball[:xSpeed]
    end
  end

  def ballCollidesWithSides(state)
    if state.ball[:x] < 0
      state.gameOver = true
    end
    if state.ball[:x] > 1280
      state.gameOver = true
    end
  end

  def render(graphics, state)
    graphics.sprites << {x:0, y:0, w:1280, h:720, path: :pixel, r: 0, g: 0, b: 0}
    graphics.sprites << state.paddles[:one]
    graphics.sprites << state.paddles[:two]
    graphics.sprites << state.ball
  end

end
