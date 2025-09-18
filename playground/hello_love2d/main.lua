local font, gameTitle, x, y, circle_x, circle_speed

require("input")


function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.2)

    font = love.graphics.newFont(36)
    love.graphics.setFont(font)

    gameTitle = "Hello World!"
    x = 400
    y = 275

    circle_x = 0
    circle_speed = 100
end

function love.update(dt)
    x = 300 + math.sin(love.timer.getTime() * 2.5) * 75

    circle_x = circle_x + circle_speed * dt
    if circle_x > love.graphics.getWidth() then
        circle_x = 0
    end
end

function love.draw()
    love.graphics.print(gameTitle, x, y)
    love.graphics.circle("line", circle_x, 100, 10)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Press ESC to quit", 10, love.graphics.getHeight() - 50)
end

function love.quit()
    print("Quit the game")
    return false
end
