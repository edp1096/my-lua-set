local font, gameTitle, x, y, time

function love.load()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.2)

    font = love.graphics.newFont(36)
    love.graphics.setFont(font)

    gameTitle = "Hello World!"
    x = 400
    y = 275
    time = 0
end

function love.update(dt)
    time = time + dt
    -- x = 325 + math.sin(love.timer.getTime() * 2.5) * 75
    x = 300 + math.sin(time * 2.5) * 75
end

function love.draw()
    love.graphics.print(gameTitle, x, y)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Press ESC to quit", 10, love.graphics.getHeight() - 30)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.keyreleased(key) end

function love.mousepressed(mx, my, button, istouch, presses)
    if button == 1 then
        print("Mouse clicked at: " .. mx .. ", " .. my)
    end
end

function love.mousereleased(mx, my, button, istouch, presses) end

function love.quit()
    print("Thanks for playing!")
    return false
end
