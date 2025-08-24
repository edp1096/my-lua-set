-- simple_player.lua - 원래 코드 스타일 + util.dll

local audio = require("audio")

print("Simple Audio Test")

local fname = "music/guitar.mp3"

audio.init()

local sound = audio.load(fname)
if not sound then
    print("Failed to load " .. fname)
    return
end

print("Loaded " .. fname)

sound:setVolume(0.2)
sound:play()

print("Playing... Press Enter to stop")

-- 기존 io.read() 대신 non-blocking 버전
while sound:isPlaying() do
    if audio.kbhit() then
        local key = audio.getch()
        if key == audio.KEY.ENTER then
            break  -- 엔터 누르면 정지
        end
    end
    audio.msleep(100)  -- 0.1초마다 체크
end

-- 결과 처리
if sound:isPlaying() then
    print("Stopped by user")
    sound:stop()
else
    print("Music finished!")
end

audio.shutdown()

print("Done!")