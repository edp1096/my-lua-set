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
