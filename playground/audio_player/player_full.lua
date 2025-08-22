-- player_full.lua - Full featured audio player

local audio = require("audio")
local util = require("util")

print("Full Audio Player v1.0")
print("Util version:", util.version)

local fname = "music/guitar.flac"

audio.init()

local sound = audio.load(fname)
if not sound then
    print("Failed to load " .. fname)
    return
end

print("Loaded " .. fname)

-- 음악 재생 설정
sound:setVolume(0.2)
sound:play()

print("Playing... Press Enter to stop (or wait for auto-finish)")
print("Controls: Space=Pause/Resume, -/+=Volume, Q/ESC/Enter=Quit, Arrows=Test")

-- 메인 루프: 키 입력과 음악 상태를 동시에 체크
local user_stopped = false
local is_paused = false
local current_volume = 0.2

while (sound:isPlaying() or is_paused) and not user_stopped do
    -- 키 입력 체크
    if util.kbhit() then
        local key = util.getch()

        if key == util.KEY.ENTER then
            print("Enter pressed - stopping...")
            user_stopped = true
            break
        elseif key == util.KEY.ESC then
            print("ESC pressed - quitting...")
            user_stopped = true
            break
        elseif key == util.KEY.SPACE then
            -- 스페이스바로 일시정지/재생 토글
            if is_paused then
                sound:play()
                is_paused = false
                print("Resumed")
            else
                sound:stop()
                is_paused = true
                print("Paused (Press Space to resume)")
            end
        elseif key == util.KEY.MINUS then
            -- 볼륨 감소
            current_volume = current_volume - 0.05
            if current_volume < 0.0 then current_volume = 0.0 end
            sound:setVolume(current_volume)
            print("Volume: " .. math.floor(current_volume * 100) .. "%")
            util.beep(400, 50)
        elseif key == util.KEY.EQUAL then
            -- 볼륨 증가
            current_volume = current_volume + 0.05
            if current_volume > 1.0 then current_volume = 1.0 end
            sound:setVolume(current_volume)
            print("Volume: " .. math.floor(current_volume * 100) .. "%")
            util.beep(800, 50)
        elseif key == util.KEY.TAB then
            print("Tab - not implemented")
        elseif key == util.KEY.BACKSPACE then
            print("Backspace - not implemented")
        elseif key == string.byte('q') or key == string.byte('Q') then
            print("'Q' pressed - quitting...")
            user_stopped = true
            break
        end
    end

    -- 음악이 자연스럽게 끝났는지 체크 (일시정지 상태가 아닐 때만)
    if not is_paused and not sound:isPlaying() then
        print("Music finished!")
        break
    end

    -- CPU 효율적인 짧은 대기
    util.msleep(50) -- 50ms = 0.05초
end

-- 결과 처리
if user_stopped then
    if sound:isPlaying() then
        sound:stop()
    end
    print("Stopped by user")
    util.beep(600, 100) -- 정지 효과음
else
    print("Music completed")
    util.beep(800, 200) -- 완료 효과음
end

-- 정리
audio.shutdown()
print("Done!")

util.sleep(1) -- 1초 대기 후 종료
