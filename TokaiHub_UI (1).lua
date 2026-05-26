-- ╔══════════════════════════════════════════════════╗
-- ║           TokaiHub — Roblox UI Library           ║
-- ║  Volt · Potassium · Synapse Z · Volcano · Wave   ║
-- ║  Delta · Codex · Seliwar · Solar · Xeno + more   ║
-- ╚══════════════════════════════════════════════════╝

local UserInputService = game:GetService("UserInputService")

local TweenService     = game:GetService("TweenService")
local SoundService     = game:GetService("SoundService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Camera           = workspace.CurrentCamera

-- ═══════════════════════════════════════════════
--  GITHUB ASSET LOADER  (lấy từ TokaiHub v1)
--  Tải ảnh/âm thanh từ GitHub → cache local
--  Dùng getcustomasset() → load vào UI không cần Roblox ID
-- ═══════════════════════════════════════════════

local REPO      = "https://raw.githubusercontent.com/longhazem/ui-library-/main/"
local CACHE_DIR = "TokaiHub"

local function EnsureDir(path)
    pcall(function()
        if not isfolder(path) then makefolder(path) end
    end)
end
EnsureDir(CACHE_DIR)

local VERSION = "1.0.0"
local verPath = CACHE_DIR .. "/version.txt"
local function CheckVersion()
    local ok, ver = pcall(readfile, verPath)
    if not ok or ver ~= VERSION then
        pcall(function()
            local files = listfiles(CACHE_DIR)
            for _, f in ipairs(files or {}) do pcall(delfile, f) end
        end)
        pcall(writefile, verPath, VERSION)
        return false
    end
    return true
end
local cacheValid = CheckVersion()

local ASSET_MAP = {
    homeIcon     = { path = CACHE_DIR.."/TOKAI_logo_no_bg.png",  url = REPO.."models/TOKAI_logo_no_bg.png" },
    tabHome      = { path = CACHE_DIR.."/tab_home.png",          url = REPO.."models/Home-Chimney-2--Streamline-Freehand-1.png" },
    tabMain      = { path = CACHE_DIR.."/tab_main.png",          url = REPO.."models/Search-Magnifier--Streamline-Freehand-1.png" },
    tabDisplay   = { path = CACHE_DIR.."/tab_display.png",       url = REPO.."models/View-Eye-1--Streamline-Freehand-1.png" },
    tabClose     = { path = CACHE_DIR.."/tab_close.png",         url = REPO.."models/Login-Rectangle--Streamline-Freehand-1.png" },
    tabSettings  = { path = CACHE_DIR.."/tab_settings.png",      url = REPO.."models/Settings-Cog-Double-1--Streamline-Freehand-1.png" },
    lockIcon     = { path = CACHE_DIR.."/lock_icon.png",         url = REPO.."models/Lock-Circle--Streamline-Freehand-1.png" },
    unlockIcon   = { path = CACHE_DIR.."/unlock_icon.png",       url = REPO.."models/Unlock-Circle--Streamline-Freehand-1.png" },
    openSound    = { path = CACHE_DIR.."/open.mp3",              url = REPO.."audio module/open.mp3" },
    clickSound   = { path = CACHE_DIR.."/click.mp3",             url = REPO.."audio module/click.mp3" },
    humanIcon    = { path = CACHE_DIR.."/human_icon.png",        url = REPO.."models/icons8-human-50.png" },
    gunIcon      = { path = CACHE_DIR.."/gun_icon.png",           url = REPO.."models/icons8-gun-50.png" },
    secretSound  = { path = CACHE_DIR.."/secret.mp3",             url = REPO.."audio module/YTDown_YouTube_KRUX-Illusion-of-Inflict-slowed_Media_u_HbqssDLqI_007_128k.mp3" },
    click1       = { path = CACHE_DIR.."/click1.wav",             url = REPO.."audio module/mixkit-cool-interface-click-tone-2568.wav" },
    click2       = { path = CACHE_DIR.."/click2.wav",             url = REPO.."audio module/mixkit-hard-typewriter-click-1119.wav" },
    click3       = { path = CACHE_DIR.."/click3.wav",             url = REPO.."audio module/mixkit-typewriter-soft-click-1125.wav" },
    bellSound    = { path = CACHE_DIR.."/bell.mp3",               url = REPO.."audio module/old-church-bell-meme.mp3" },
}

local loadedAssets = {}

local function LoadAsset(key)
    local info = ASSET_MAP[key]
    if not info then return nil end

    local cached = false
    if cacheValid then
        local ok, exists = pcall(isfile, info.path)
        cached = ok and exists
    end

    if not cached then
        local dlOk, data = pcall(game.HttpGet, game, info.url)
        if dlOk and data and #data > 10 then
            pcall(writefile, info.path, data)
            print("[TokaiHub] Cached: "..key)
        else
            warn("[TokaiHub] Download failed: "..key)
            return nil
        end
    end

    local assetOk, assetPath = pcall(getcustomasset, info.path)
    if assetOk and assetPath then
        loadedAssets[key] = assetPath
        return assetPath
    end
    return nil
end

-- Preload tất cả asset từ GitHub trong background
task.spawn(function()
    for key in pairs(ASSET_MAP) do
        LoadAsset(key)
    end
end)

-- GetAsset: trả về asset đã load hoặc fallback nếu chưa sẵn sàng
local function GetAsset(key, fallback)
    return loadedAssets[key] or fallback or ""
end

-- ═══════════════════════════════════════════════

local startTime = os.time()
local gmtOffset = 7  -- GMT+7 mặc định (Việt Nam), thay đổi qua Settings
_G.ToggleKey   = Enum.KeyCode.RightControl
local isLocked = false
local DISCORD  = "https://discord.gg/nn783R2fK2"

-- ═══════════════════════════════════════════════
--  EXECUTOR COMPATIBILITY LAYER
-- ═══════════════════════════════════════════════

local function GetGuiParent()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then return cg end
    return Players.LocalPlayer:WaitForChild("PlayerGui", 5)
        or Players.LocalPlayer.PlayerGui
end

local function SafeCopy(text)
    if setclipboard then pcall(setclipboard, text); return end
    if toclipboard  then pcall(toclipboard,  text); return end
    if Clipboard and Clipboard.set then pcall(function() Clipboard.set(text) end); return end
    if syn and syn.write_clipboard then pcall(syn.write_clipboard, text) end
end

local SAVE_FILE = "TokaiHubSave.json"

local function SafeWrite(name, content)
    pcall(function() if writefile then writefile(name, content) end end)
end

local function SafeRead(name)
    local ok, data = pcall(function()
        if not isfile or not readfile then return nil end
        if not isfile(name) then return nil end
        return readfile(name)
    end)
    return (ok and type(data) == "string") and data or nil
end

local function Serialize(t)
    local parts = {}
    for k, v in pairs(t) do
        local vs = type(v) == "boolean" and (v and "true" or "false") or tostring(v)
        table.insert(parts, k .. "=" .. vs)
    end
    return table.concat(parts, ";")
end

local function Deserialize(s, default)
    local t = {}
    for k, v in pairs(default) do t[k] = v end
    if not s or s == "" then return t end
    for pair in s:gmatch("([^;]+)") do
        local k, v = pair:match("^(.-)=(.+)$")
        if k and v then
            if v == "true"  then t[k] = true
            elseif v == "false" then t[k] = false
            else local n = tonumber(v); if n then t[k] = n end
            end
        end
    end
    return t
end

local DEFAULT = {}
local function LoadSettings()
    local raw = SafeRead(SAVE_FILE)
    return Deserialize(raw, DEFAULT)
end
local S = LoadSettings()
local function Save() SafeWrite(SAVE_FILE, Serialize(S)) end

-- ════════════════════════════════════════════
--  FIX DECAL → TEXTURE
--  Roblox Decal asset khác với Image asset.
--  Hàm này tự động lấy Texture thật từ Decal ID.
-- ════════════════════════════════════════════
local decalCache = {}
local function ResolveImage(idOrUrl)
    local idStr = tostring(idOrUrl):match("%d+") or tostring(idOrUrl)
    if decalCache[idStr] then return decalCache[idStr] end
    local url = "rbxassetid://" .. idStr
    local ok, obj = pcall(function()
        return game:GetObjects(url)[1]
    end)
    if ok and obj then
        if obj:IsA("Decal") or obj:IsA("Texture") then
            local tex = obj.Texture
            obj:Destroy()
            decalCache[idStr] = tex
            return tex
        end
        pcall(function() obj:Destroy() end)
    end
    decalCache[idStr] = url
    return url
end

-- ═══════════════ CLEANUP ═══════════════
local function CleanupOldUI()
    local gui = GetGuiParent()
    local old = gui:FindFirstChild("TOKAIHUB")
    if old then old:Destroy() end
    local oldOverlay = gui:FindFirstChild("TOKAIHUB_OVERLAY")
    if oldOverlay then oldOverlay:Destroy() end
end
CleanupOldUI()

-- ═══════════════ CLICK SOUND ═══════════════
-- Dùng GetAsset() → tự dùng file GitHub nếu đã cache, không thì fallback rbxassetid
local clickKeys = {"click1","click2","click3"}
local function PlayClickSound()
    local key = clickKeys[math.random(1,#clickKeys)]
    local s = Instance.new("Sound")
    local asset = GetAsset(key,"")
    s.SoundId = asset ~= "" and asset or GetAsset("clickSound","rbxassetid://126347354635406")
    s.Volume = 0.6
    s.Parent = SoundService; s:Play()
    game:GetService("Debris"):AddItem(s, 2)
end

-- ═══════════════ TOAST ═══════════════
local toastQueue = {}
local toastRunning = false

local function ShowToast(msg, icon)
    icon = icon or "✨"
    table.insert(toastQueue, { msg = msg, icon = icon })
    if toastRunning then return end
    toastRunning = true
    coroutine.wrap(function()
        while #toastQueue > 0 do
            local item = table.remove(toastQueue, 1)
            local sg = Instance.new("ScreenGui", GetGuiParent())
            sg.Name = "TokaiToast"; sg.IgnoreGuiInset = true; sg.ResetOnSpawn = false
            local toastW = 220
            local toast = Instance.new("Frame", sg)
            toast.Size = UDim2.new(0, toastW, 0, 38)
            toast.Position = UDim2.new(0.5, -toastW/2, 0, -44)
            toast.BackgroundColor3 = Color3.fromRGB(255, 182, 193)
            toast.BackgroundTransparency = 0.08
            Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 12)
            local stroke = Instance.new("UIStroke", toast)
            stroke.Color = Color3.fromRGB(235,110,140); stroke.Thickness = 1.5
            local iconBg = Instance.new("Frame", toast)
            iconBg.Size = UDim2.new(0,32,1,0); iconBg.BackgroundColor3 = Color3.fromRGB(235,110,140)
            iconBg.BackgroundTransparency = 0.2
            Instance.new("UICorner", iconBg).CornerRadius = UDim.new(0,12)
            local iconLbl = Instance.new("TextLabel", iconBg)
            iconLbl.Size = UDim2.new(1,0,1,0); iconLbl.Text = item.icon
            iconLbl.Font = Enum.Font.GothamBold; iconLbl.TextSize = 16
            iconLbl.BackgroundTransparency = 1; iconLbl.TextColor3 = Color3.new(1,1,1)
            local msgLbl = Instance.new("TextLabel", toast)
            msgLbl.Size = UDim2.new(1,-40,1,0); msgLbl.Position = UDim2.new(0,36,0,0)
            msgLbl.Text = item.msg; msgLbl.Font = Enum.Font.GothamBold; msgLbl.TextSize = 10
            msgLbl.TextColor3 = Color3.fromRGB(90,45,55); msgLbl.BackgroundTransparency = 1
            msgLbl.TextXAlignment = Enum.TextXAlignment.Left; msgLbl.TextWrapped = true
            TweenService:Create(toast, TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
                {Position=UDim2.new(0.5,-toastW/2,0,18)}):Play()
            task.wait(2.2)
            TweenService:Create(toast, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
                {Position=UDim2.new(0.5,-toastW/2,0,-50), BackgroundTransparency=1}):Play()
            task.wait(0.35); sg:Destroy(); task.wait(0.1)
        end
        toastRunning = false
    end)()
end

-- ═══════════════ UI LIBRARY ═══════════════
local Library = {}

function Library:CreateWindow()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TOKAIHUB"
    screenGui.DisplayOrder = 10
    screenGui.Parent = GetGuiParent()
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true

    -- Âm thanh mở: thử dùng file GitHub trước, fallback rbxassetid
    do
        local os2 = Instance.new("Sound")
        os2.SoundId = GetAsset("openSound", "rbxassetid://88375863598461")
        os2.Volume = 1
        os2.Parent = SoundService; os2:Play()
        game:GetService("Debris"):AddItem(os2, 5)
        -- Nếu GitHub asset chưa load kịp → chờ và phát lại bằng file cache
        task.spawn(function()
            for _ = 1, 20 do
                task.wait(0.3)
                local cached = GetAsset("openSound", "")
                if cached ~= "" and os2.SoundId ~= cached then
                    -- Đã cache xong nhưng âm thanh đã phát rồi, thôi bỏ qua
                    break
                end
            end
        end)
    end

    local MainColor = Color3.fromRGB(255, 182, 193)
    local TextColor = Color3.fromRGB(90, 45, 55)
    local DarkPink  = Color3.fromRGB(235, 110, 140)
    local Green     = Color3.fromRGB(34, 197, 94)
    local Gray      = Color3.fromRGB(160, 160, 160)

    -- ════════════════════════════════════════════
    --  IMAGE IDs — kết hợp GitHub Asset + ResolveImage fallback
    --  · close / keybind: dùng ResolveImage() (không có trên GitHub)
    --  · lock / unlock:   ưu tiên ảnh GitHub, fallback Decal resolve
    -- ════════════════════════════════════════════
    local ICONS = {
        close   = GetAsset("tabClose", ResolveImage("7072725342")),
        lock    = GetAsset("lockIcon",   ResolveImage("77585429015889")),
        unlock  = GetAsset("unlockIcon", ResolveImage("122613499308444")),
        keybind = ResolveImage("7072718840"),
    }

    -- Helper: async cập nhật image của button khi GitHub asset load xong
    local function AsyncUpdateIcon(btn, assetKey, fallbackUrl)
        task.spawn(function()
            for _ = 1, 40 do
                task.wait(0.3)
                local img = GetAsset(assetKey, "")
                if img ~= "" then
                    btn.Image = img
                    ICONS[assetKey == "lockIcon" and "lock" or
                          assetKey == "unlockIcon" and "unlock" or
                          assetKey == "homeIcon" and "home" or assetKey] = img
                    break
                end
            end
        end)
    end

    -- ════ OPEN BUTTON ════
    local openBtn = Instance.new("ImageButton", screenGui)
    openBtn.Name = "OpenButton"; openBtn.Size = UDim2.new(0,50,0,50)
    openBtn.Position = UDim2.new(0,10,0.5,-25)
    openBtn.BackgroundColor3 = MainColor
    -- Bắt đầu bằng rbxthumb, async cập nhật homeIcon từ GitHub khi sẵn
    openBtn.Image = "rbxthumb://type=Asset&id=99217897221957&w=420&h=420"
    openBtn.Visible = true
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1,0)
    local openStroke = Instance.new("UIStroke", openBtn); openStroke.Thickness = 3

    -- Async load homeIcon từ GitHub cho openBtn
    task.spawn(function()
        for _ = 1, 40 do
            task.wait(0.3)
            local img = GetAsset("homeIcon", "")
            if img ~= "" then
                openBtn.Image = img
                break
            end
        end
    end)

    -- ════ IDLE BREATHING ANIMATION cho openBtn ════
    coroutine.wrap(function()
        while openBtn and openBtn.Parent do
            if openBtn.Visible then
                TweenService:Create(openBtn, TweenInfo.new(1.1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {Size=UDim2.new(0,55,0,55)}):Play()
                task.wait(1.1)
                TweenService:Create(openBtn, TweenInfo.new(1.1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {Size=UDim2.new(0,50,0,50)}):Play()
                task.wait(1.1)
            else
                task.wait(0.5)
            end
        end
    end)()

    local screenW = Camera.ViewportSize.X
    local FRAME_W = math.clamp(math.floor(screenW * 0.88), 300, 390)
    local FRAME_H = 240

    local main = Instance.new("Frame")
    main.Name = "MainFrame"; main.Size = UDim2.new(0, FRAME_W, 0, FRAME_H)
    main.Position = UDim2.new(0.5,0,0.5,0); main.AnchorPoint = Vector2.new(0.5,0.5)
    main.BackgroundColor3 = MainColor; main.BackgroundTransparency = 0.3
    main.Parent = screenGui; main.ClipsDescendants = false
    main.Visible = false
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,15)
    local mainStroke = Instance.new("UIStroke", main); mainStroke.Thickness = 2

    local tabOrder = 0
    local function AttachCardGlow(f, phase, spd, thick)
        phase=phase or 0; spd=spd or 22; thick=thick or 1.5
        local st=Instance.new("UIStroke",f); st.Thickness=thick; st.Color=Color3.new(1,1,1)
        st.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        local gr=Instance.new("UIGradient",st)
        gr.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,182,193)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(230,150,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,182,193))})
        gr.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.10,0.9),NumberSequenceKeypoint.new(0.20,0),NumberSequenceKeypoint.new(0.35,0.9),NumberSequenceKeypoint.new(0.5,1),NumberSequenceKeypoint.new(0.65,0.9),NumberSequenceKeypoint.new(0.80,0),NumberSequenceKeypoint.new(0.90,0.9),NumberSequenceKeypoint.new(1,1)})
        coroutine.wrap(function()
            local rot=phase; local last=tick()
            while f and f.Parent do RunService.Heartbeat:Wait(); local now=tick(); local dt=now-last; last=now; rot=(rot+spd*dt)%360; gr.Rotation=rot end
        end)()
        return st
    end

    -- ════ TOOLBAR ════
    local toolbar = Instance.new("Frame", main)
    toolbar.Size = UDim2.new(0,30,0,95)
    toolbar.Position = UDim2.new(1,62,0.5,-47)
    toolbar.BackgroundColor3 = Color3.new(1,1,1)
    toolbar.BackgroundTransparency = 0.5
    Instance.new("UICorner", toolbar).CornerRadius = UDim.new(0,8)
    AttachCardGlow(toolbar,270,20,1.5)
    local tbl = Instance.new("UIListLayout", toolbar)
    tbl.Padding = UDim.new(0,5)
    tbl.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tbl.VerticalAlignment   = Enum.VerticalAlignment.Center

    local function MakeToolImgBtn(imageUrl, col)
        local b = Instance.new("ImageButton", toolbar)
        b.Size = UDim2.new(0,22,0,22)
        b.BackgroundColor3 = col
        b.Image = imageUrl
        b.ScaleType = Enum.ScaleType.Fit
        local pad = Instance.new("UIPadding", b)
        pad.PaddingTop = UDim.new(0,3); pad.PaddingBottom = UDim.new(0,3)
        pad.PaddingLeft = UDim.new(0,3); pad.PaddingRight = UDim.new(0,3)
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
        local bs = Instance.new("UIStroke", b)
        bs.Color = Color3.new(1,1,1); bs.Thickness = 1.5; bs.Transparency = 0.8
        b.MouseEnter:Connect(function()
            TweenService:Create(b,  TweenInfo.new(0.15,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,25,0,25)}):Play()
            TweenService:Create(bs, TweenInfo.new(0.15), {Transparency=0.2}):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b,  TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size=UDim2.new(0,22,0,22)}):Play()
            TweenService:Create(bs, TweenInfo.new(0.15), {Transparency=0.8}):Play()
        end)
        b.MouseButton1Down:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.07), {Size=UDim2.new(0,19,0,19)}):Play()
        end)
        b.MouseButton1Up:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,22,0,22)}):Play()
        end)
        return b
    end

    local closeBtn = MakeToolImgBtn(ICONS.close,   Color3.fromRGB(235,80,80))
    local lockBtn  = MakeToolImgBtn(ICONS.unlock,  Color3.fromRGB(80,200,80))
    local keyBtn   = MakeToolImgBtn(ICONS.keybind, DarkPink)

    -- Async cập nhật icon — ban đầu là unlockIcon vì isLocked=false
    AsyncUpdateIcon(lockBtn, "unlockIcon", ResolveImage("122613499308444"))
    AsyncUpdateIcon(closeBtn, "tabClose",  ResolveImage("7072725342"))

    local overlayGui = Instance.new("ScreenGui", GetGuiParent())
    overlayGui.Name = "TOKAIHUB_OVERLAY"
    overlayGui.ResetOnSpawn = false; overlayGui.IgnoreGuiInset = true; overlayGui.DisplayOrder = -1
    local overlay = Instance.new("Frame", overlayGui)
    overlay.Size = UDim2.new(1,0,1,0); overlay.BackgroundColor3 = Color3.fromRGB(10,5,10)
    overlay.BackgroundTransparency = 1; overlay.Visible = false; overlay.Active = false

    local activeDropdown = nil
    local isTweening = false

    local function ToggleUI()
        if isTweening then return end; isTweening = true
        -- Đóng GMT dropdown nếu đang mở
        for _,v in pairs(main:GetChildren()) do
            if v:IsA("Frame") and v.ZIndex==200 then v.Visible=false end
        end
        if main.Visible then
            if activeDropdown then activeDropdown(true) end
            -- Lưu vị trí trước khi đóng
            local savedPos = main.Position
            TweenService:Create(overlay, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency=1}):Play()
            TweenService:Create(main, TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.In),
                {Size=UDim2.new(0,FRAME_W*0.05,0,FRAME_H*0.05), BackgroundTransparency=1}):Play()
            task.delay(0.35, function()
                main.Visible = false
                main.BackgroundTransparency = 0.3
                main.Position = savedPos       -- giữ nguyên vị trí
                main.Size = UDim2.new(0,FRAME_W,0,FRAME_H)  -- reset size về full
                overlay.Visible = false; openBtn.Visible = true
                openBtn.Size = UDim2.new(0,0,0,0)
                TweenService:Create(openBtn, TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,50,0,50)}):Play()
                isTweening = false
            end)
        else
            openBtn.Visible = false
            overlay.Visible = true; overlay.BackgroundTransparency = 1
            TweenService:Create(overlay, TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency=0.5}):Play()
            -- Nếu đang lock thì mở lại đúng vị trí cũ, không reset về giữa
            if not isLocked then
                main.Position = UDim2.new(0.5,0,0.5,0)
            end
            main.Visible = true
            main.Size = UDim2.new(0,FRAME_W*0.05,0,FRAME_H*0.05); main.BackgroundTransparency = 1
            TweenService:Create(main, TweenInfo.new(0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
                {Size=UDim2.new(0,FRAME_W,0,FRAME_H), BackgroundTransparency=0.3}):Play()
            task.delay(0.45, function() isTweening = false end)
        end
    end

    closeBtn.MouseButton1Click:Connect(function()
        PlayClickSound(); ToggleUI()
    end)
    openBtn.MouseButton1Click:Connect(function() PlayClickSound(); ToggleUI() end)
    lockBtn.MouseButton1Click:Connect(function()
        PlayClickSound(); isLocked = not isLocked
        lockBtn.Image = isLocked
            and GetAsset("lockIcon",   ICONS.lock)
            or  GetAsset("unlockIcon", ICONS.unlock)
        lockBtn.BackgroundColor3 = isLocked and Color3.fromRGB(200,80,80) or Color3.fromRGB(80,200,80)
    end)
    local isBinding = false
    keyBtn.MouseButton1Click:Connect(function()
        if isBinding then return end
        PlayClickSound(); isBinding = true; keyBtn.ImageTransparency = 0.5
        local c; c = UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                _G.ToggleKey = inp.KeyCode; keyBtn.ImageTransparency = 0
                isBinding = false; c:Disconnect()
            end
        end)
    end)

    coroutine.wrap(function()
        local cols = {Color3.fromRGB(255,255,255), Color3.fromRGB(255,192,203), Color3.fromRGB(230,190,255)}
        while task.wait() do
            local t = (math.sin(tick()*2)+1)/2
            local c = cols[1]:Lerp(cols[2],t):Lerp(cols[3],(math.cos(tick()*1.5)+1)/2)
            mainStroke.Color = c; openStroke.Color = c
        end
    end)()

    -- ════ GLOW BORDER — 2 border xoay lệch 180° ════
    local function CreateGlowBorder(phaseOffset)
        phaseOffset = phaseOffset or 0
        local border = Instance.new("Frame", screenGui)
        border.Name = "__GlowBorder"
        border.Size = UDim2.new(0,FRAME_W,0,FRAME_H); border.Position = main.Position
        border.AnchorPoint = Vector2.new(0.5,0.5); border.BackgroundTransparency = 1
        border.ZIndex = 2; border.Active = false
        Instance.new("UICorner", border).CornerRadius = UDim.new(0,15)
        local stroke = Instance.new("UIStroke", border)
        stroke.Thickness = 2; stroke.Color = Color3.new(1,1,1)
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local grad = Instance.new("UIGradient", stroke)
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
        })
        grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,    1),
            NumberSequenceKeypoint.new(0.08, 0.95),
            NumberSequenceKeypoint.new(0.18, 0),
            NumberSequenceKeypoint.new(0.32, 0.95),
            NumberSequenceKeypoint.new(0.5,  1),
            NumberSequenceKeypoint.new(0.68, 0.95),
            NumberSequenceKeypoint.new(0.82, 0),
            NumberSequenceKeypoint.new(0.92, 0.95),
            NumberSequenceKeypoint.new(1,    1),
        })
        coroutine.wrap(function()
            while true do
                RunService.Heartbeat:Wait()
                border.Visible = main.Visible; border.Position = main.Position
            end
        end)()
        coroutine.wrap(function()
            local rot = phaseOffset; local spd = 18; local last = tick()
            while true do
                RunService.Heartbeat:Wait()
                local now = tick(); local dt = now-last; last = now
                rot = (rot + spd*dt) % 360; grad.Rotation = rot
            end
        end)()
    end

    task.defer(function()
        task.wait(0.1)
        for _, v in ipairs(screenGui:GetChildren()) do
            if v.Name == "__GlowBorder" then v:Destroy() end
        end
        CreateGlowBorder(0); CreateGlowBorder(180)
    end)

    UserInputService.InputBegan:Connect(function(inp, gpe)
        if not gpe and inp.KeyCode == _G.ToggleKey then PlayClickSound(); ToggleUI() end
    end)

    local dragLocked = false
    local function EnableDrag(obj)
        local dragging, dragInput, dragStart, startPos
        obj.InputBegan:Connect(function(inp)
            if isLocked or dragLocked then return end
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                dragging=true; dragStart=inp.Position; startPos=obj.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState==Enum.UserInputState.End then dragging=false end
                end)
            end
        end)
        obj.InputChanged:Connect(function(inp)
            if not isLocked and not dragLocked and
               (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
                dragInput = inp
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if inp==dragInput and dragging and not isLocked and not dragLocked then
                local d = inp.Position - dragStart
                obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                dragging=false; dragLocked=false
            end
        end)
    end

    local function AttachScrollLock(sf)
        local touchStart = nil
        sf.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Touch then touchStart=inp.Position end
        end)
        sf.InputChanged:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Touch and touchStart then
                local dy = math.abs(inp.Position.Y - touchStart.Y)
                local dx = math.abs(inp.Position.X - touchStart.X)
                if dy > dx and dy > 6 then dragLocked = true end
            end
        end)
        sf.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Touch then touchStart=nil; dragLocked=false end
        end)
    end

    EnableDrag(main)
    do
        local dragging,dragStart,startPos,didDrag
        openBtn.InputBegan:Connect(function(inp)
            if isLocked or dragLocked then return end
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                dragging=true; didDrag=false; dragStart=inp.Position; startPos=openBtn.Position
            end
        end)
        openBtn.InputChanged:Connect(function(inp)
            if not dragging or isLocked or dragLocked then return end
            if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
                local d=inp.Position-dragStart
                if math.abs(d.X)>8 or math.abs(d.Y)>8 then
                    didDrag=true
                    openBtn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
                end
            end
        end)
        openBtn.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                if dragging and not didDrag then PlayClickSound(); ToggleUI() end
                dragging=false; didDrag=false
            end
        end)
    end

    -- ════ SIDEBAR ════
    local sidebar = Instance.new("ScrollingFrame", main)
    sidebar.Size = UDim2.new(0,35,0,200); sidebar.Position = UDim2.new(1,8,0.5,-100)
    sidebar.BackgroundColor3 = Color3.fromRGB(255,255,255); sidebar.BackgroundTransparency = 0.65
    sidebar.ScrollBarThickness=0; sidebar.ScrollingDirection=Enum.ScrollingDirection.Y
    sidebar.CanvasSize=UDim2.new(0,0,0,0); sidebar.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sidebar.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable; sidebar.ScrollingEnabled=true; sidebar.ClipsDescendants=true
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(1,0)
    AttachCardGlow(sidebar,90,20,1.5)
    local sbl = Instance.new("UIListLayout", sidebar)
    sbl.Padding = UDim.new(0,7); sbl.HorizontalAlignment=Enum.HorizontalAlignment.Center
    sbl.VerticalAlignment=Enum.VerticalAlignment.Top; sbl.SortOrder=Enum.SortOrder.LayoutOrder
    local sbPad=Instance.new("UIPadding",sidebar); sbPad.PaddingTop=UDim.new(0,6); sbPad.PaddingBottom=UDim.new(0,6)
    local arrowUp=Instance.new("TextLabel",main); arrowUp.Size=UDim2.new(0,20,0,11); arrowUp.Position=UDim2.new(1,8,0.5,-106)
    arrowUp.Text="▴"; arrowUp.Font=Enum.Font.GothamBold; arrowUp.TextSize=9; arrowUp.TextColor3=Color3.fromRGB(235,110,140); arrowUp.BackgroundTransparency=1; arrowUp.TextXAlignment=Enum.TextXAlignment.Center; arrowUp.Visible=false
    local arrowDown=Instance.new("TextLabel",main); arrowDown.Size=UDim2.new(0,20,0,11); arrowDown.Position=UDim2.new(1,8,0.5,95)
    arrowDown.Text="▾"; arrowDown.Font=Enum.Font.GothamBold; arrowDown.TextSize=9; arrowDown.TextColor3=Color3.fromRGB(235,110,140); arrowDown.BackgroundTransparency=1; arrowDown.TextXAlignment=Enum.TextXAlignment.Center; arrowDown.Visible=false
    local function UpdateSidebarArrows()
        local pos=sidebar.CanvasPosition.Y; local ms=sidebar.AbsoluteCanvasSize.Y-sidebar.AbsoluteSize.Y
        arrowUp.Visible=pos>4; arrowDown.Visible=ms>4 and pos<ms-4
    end
    sidebar:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdateSidebarArrows)
    sidebar:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(UpdateSidebarArrows)
    AttachScrollLock(sidebar)

    local tabContainer = Instance.new("Frame", main)
    tabContainer.Size = UDim2.new(0,335,0,215); tabContainer.Position = UDim2.new(0,28,0,10)
    tabContainer.BackgroundTransparency = 1; tabContainer.ClipsDescendants = true

    local pages = Instance.new("Frame", tabContainer)
    pages.Size = UDim2.new(1,0,1,0); pages.BackgroundTransparency = 1; pages.Active = false

    -- ════ ELEMENT HELPERS ════
    local function MakeAnimButton(parent, text, yPos, callback, toastMsg, toastIcon)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1,-4,0,28); btn.Position = UDim2.new(0,2,0,yPos)
        btn.BackgroundColor3 = Color3.fromRGB(255,255,255); btn.BackgroundTransparency = 0.45
        btn.Text = text; btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = TextColor; btn.TextSize = 10; btn.ClipsDescendants = true
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,7)
        local stroke = Instance.new("UIStroke", btn); stroke.Color = DarkPink; stroke.Thickness = 1.2
        local function SpawnRipple(inputX, inputY)
            local ripple = Instance.new("Frame", btn)
            local rx = inputX - btn.AbsolutePosition.X
            local ry = inputY - btn.AbsolutePosition.Y
            local maxR = math.sqrt(btn.AbsoluteSize.X^2 + btn.AbsoluteSize.Y^2) * 1.5
            ripple.Size = UDim2.new(0,0,0,0); ripple.Position = UDim2.new(0,rx,0,ry)
            ripple.AnchorPoint = Vector2.new(0.5,0.5); ripple.BackgroundColor3 = DarkPink
            ripple.BackgroundTransparency = 0.55; ripple.ZIndex = 5
            Instance.new("UICorner", ripple).CornerRadius = UDim.new(1,0)
            TweenService:Create(ripple, TweenInfo.new(0.85,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size=UDim2.new(0,maxR,0,maxR)}):Play()
            TweenService:Create(ripple, TweenInfo.new(0.85,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {BackgroundTransparency=1}):Play()
            game:GetService("Debris"):AddItem(ripple, 0.9)
        end
        btn.MouseButton1Click:Connect(function()
            PlayClickSound()
            local mp = UserInputService:GetMouseLocation(); SpawnRipple(mp.X, mp.Y)
            -- Squish mạnh hơn: thu nhỏ cả chiều ngang
            TweenService:Create(btn, TweenInfo.new(0.06,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
                {Size=UDim2.new(0.92,-8,0,22), Position=UDim2.new(0.04,4,0,yPos+3)}):Play()
            -- Flash màu hồng đậm rồi bounce back
            TweenService:Create(stroke, TweenInfo.new(0.06), {Color=Color3.fromRGB(255,80,120), Thickness=2.5}):Play()
            task.delay(0.06, function()
                TweenService:Create(btn, TweenInfo.new(0.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
                    {Size=UDim2.new(1,-2,0,30), Position=UDim2.new(0,1,0,yPos-1)}):Play()
                TweenService:Create(stroke, TweenInfo.new(0.06), {Color=Color3.fromRGB(255,180,210), Thickness=2}):Play()
                task.delay(0.08, function()
                    TweenService:Create(btn, TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
                        {Size=UDim2.new(1,-4,0,28), Position=UDim2.new(0,2,0,yPos)}):Play()
                    TweenService:Create(stroke, TweenInfo.new(0.2), {Color=DarkPink, Thickness=1.2}):Play()
                end)
            end)
            if toastMsg then ShowToast(toastMsg, toastIcon) end
            if callback then callback() end
        end)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
                {BackgroundColor3=Color3.fromRGB(255,225,232), Position=UDim2.new(0,2,0,yPos-1)}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.18), {Thickness=2}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
                {BackgroundColor3=Color3.fromRGB(255,255,255), Position=UDim2.new(0,2,0,yPos)}):Play()
            TweenService:Create(stroke, TweenInfo.new(0.18), {Thickness=1.2}):Play()
        end)
        return btn
    end

    local function MakeToggle(parent, labelText, yPos, savedKey, onCallback)
        local state = S[savedKey] or false
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1,-4,0,26); row.Position = UDim2.new(0,2,0,yPos)
        row.BackgroundColor3 = Color3.fromRGB(255,255,255); row.BackgroundTransparency = 0.45
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,7)
        local rowStroke = Instance.new("UIStroke", row)
        rowStroke.Color = state and Green or Color3.fromRGB(200,200,200); rowStroke.Thickness = 1; rowStroke.Transparency = 0.5
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.7,0,1,0); lbl.Position = UDim2.new(0,8,0,0)
        lbl.Text = labelText; lbl.Font = Enum.Font.GothamBold; lbl.TextColor3 = TextColor; lbl.TextSize = 9
        lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.BackgroundTransparency = 1
        local pill = Instance.new("Frame", row)
        pill.Size = UDim2.new(0,36,0,16); pill.Position = UDim2.new(1,-42,0.5,-8)
        pill.BackgroundColor3 = state and Green or Gray
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1,0)
        local pillGlow = Instance.new("UIStroke", pill)
        pillGlow.Color = Green; pillGlow.Thickness = 2; pillGlow.Transparency = state and 0.3 or 1
        local knob = Instance.new("Frame", pill)
        knob.Size = UDim2.new(0,12,0,12)
        knob.Position = state and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
        local function SetState(newState)
            state = newState; S[savedKey] = state; Save()
            TweenService:Create(pill, TweenInfo.new(0.22,Enum.EasingStyle.Quad), {BackgroundColor3=state and Green or Gray}):Play()
            TweenService:Create(pillGlow, TweenInfo.new(0.25), {Transparency=state and 0.3 or 1}):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.25), {Color=state and Green or Color3.fromRGB(200,200,200)}):Play()
            local targetPos = state and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6)
            -- Squish rồi bounce mạnh hơn
            TweenService:Create(knob, TweenInfo.new(0.07,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Size=UDim2.new(0,8,0,15)}):Play()
            task.delay(0.07, function()
                TweenService:Create(knob, TweenInfo.new(0.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size=UDim2.new(0,16,0,10)}):Play()
                task.delay(0.08, function()
                    TweenService:Create(knob, TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
                        {Position=targetPos, Size=UDim2.new(0,12,0,12)}):Play()
                end)
            end)
            -- Row flash khi toggle
            local flashCol = state and Color3.fromRGB(210,255,220) or Color3.fromRGB(255,240,245)
            TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3=flashCol}):Play()
            task.delay(0.2, function()
                TweenService:Create(row, TweenInfo.new(0.25), {BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
            end)
            -- Pulse glow nếu bật
            if state then
                TweenService:Create(pillGlow, TweenInfo.new(0.1), {Transparency=0}):Play()
                task.delay(0.15, function()
                    TweenService:Create(pillGlow, TweenInfo.new(0.3), {Transparency=0.3}):Play()
                end)
            end
            if onCallback then onCallback(state) end
        end
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
        btn.MouseButton1Click:Connect(function() PlayClickSound(); SetState(not state) end)
        btn.MouseEnter:Connect(function() TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency=0.3}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(row, TweenInfo.new(0.15), {BackgroundTransparency=0.45}):Play() end)
        if state and onCallback then task.spawn(function() task.wait(1.2); onCallback(true) end) end
        return row
    end

    local function MakeSlider(parent, labelText, yPos, min, max, savedKey, suffix, onCallback)
        local value = S[savedKey] or min
        local KNOB_W = 13
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1,-4,0,40); row.Position = UDim2.new(0,2,0,yPos)
        row.BackgroundColor3 = Color3.fromRGB(255,255,255); row.BackgroundTransparency = 0.45; row.ClipsDescendants = false
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,7)
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.6,0,0,18); lbl.Position = UDim2.new(0,8,0,2)
        lbl.Text = labelText; lbl.Font = Enum.Font.GothamBold; lbl.TextColor3 = TextColor; lbl.TextSize = 9
        lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.BackgroundTransparency = 1
        local valLbl = Instance.new("TextLabel", row)
        valLbl.Size = UDim2.new(0.35,0,0,18); valLbl.Position = UDim2.new(0.62,0,0,2)
        valLbl.Text = tostring(value)..suffix; valLbl.Font = Enum.Font.GothamBold
        valLbl.TextColor3 = DarkPink; valLbl.TextSize = 9
        valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.BackgroundTransparency = 1
        local TRACK_PAD = 8 + math.ceil(KNOB_W/2)
        local track = Instance.new("Frame", row)
        track.Size = UDim2.new(1,-(TRACK_PAD*2),0,6); track.Position = UDim2.new(0,TRACK_PAD,0,27)
        track.BackgroundColor3 = Color3.fromRGB(220,190,200); track.ClipsDescendants = false
        Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new((value-min)/(max-min),0,1,0); fill.BackgroundColor3 = DarkPink
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
        local initPct = (value-min)/(max-min)
        local knob = Instance.new("Frame", track)
        knob.Size = UDim2.new(0,KNOB_W,0,KNOB_W)
        knob.Position = UDim2.new(initPct,-math.floor(KNOB_W*initPct),0.5,-math.ceil(KNOB_W/2))
        knob.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
        local ks = Instance.new("UIStroke", knob); ks.Color = DarkPink; ks.Thickness = 1.5
        local dragging = false
        local function UpdateFromX(absX)
            local pct = math.clamp((absX-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            value = math.floor(min+pct*(max-min)); S[savedKey]=value; Save()
            valLbl.Text = tostring(value)..suffix; fill.Size = UDim2.new(pct,0,1,0)
            knob.Position = UDim2.new(pct,-math.floor(KNOB_W*pct),0.5,-math.ceil(KNOB_W/2))
            if onCallback then onCallback(value) end
        end
        knob.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                dragging=true; dragLocked=true
                TweenService:Create(knob, TweenInfo.new(0.1,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,KNOB_W+4,0,KNOB_W-3)}):Play()
            end
        end)
        track.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                dragging=true; dragLocked=true; UpdateFromX(inp.Position.X)
                TweenService:Create(knob, TweenInfo.new(0.1,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,KNOB_W+4,0,KNOB_W-3)}):Play()
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
                UpdateFromX(inp.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                if dragging then TweenService:Create(knob, TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,KNOB_W,0,KNOB_W)}):Play() end
                dragging=false; dragLocked=false
            end
        end)
        knob.MouseEnter:Connect(function()
            if not dragging then TweenService:Create(knob, TweenInfo.new(0.15,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,KNOB_W+2,0,KNOB_W+2)}):Play() end
        end)
        knob.MouseLeave:Connect(function()
            if not dragging then TweenService:Create(knob, TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size=UDim2.new(0,KNOB_W,0,KNOB_W)}):Play() end
        end)
        return row
    end

    local function MakeDropdown(parent, labelText, yPos, options, savedKey, onCallback)
        local selected = S[savedKey] or options[1]
        local isOpen = false; local ITEM_H = 22; local HEAD_H = 26
        local head = Instance.new("Frame", parent)
        head.Size = UDim2.new(1,-4,0,HEAD_H); head.Position = UDim2.new(0,2,0,yPos)
        head.BackgroundColor3 = Color3.fromRGB(255,255,255); head.BackgroundTransparency = 0.4; head.ClipsDescendants = false
        Instance.new("UICorner", head).CornerRadius = UDim.new(0,7)
        local headStroke = Instance.new("UIStroke", head); headStroke.Color = DarkPink; headStroke.Thickness = 1.2
        local lbl = Instance.new("TextLabel", head)
        lbl.Size = UDim2.new(0,0,1,0); lbl.AutomaticSize = Enum.AutomaticSize.X; lbl.Position = UDim2.new(0,8,0,0)
        lbl.Text = labelText; lbl.Font = Enum.Font.GothamBold; lbl.TextColor3 = TextColor; lbl.TextSize = 9
        lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.BackgroundTransparency = 1
        local pillBg = Instance.new("Frame", head)
        pillBg.Size = UDim2.new(0,0,0,18); pillBg.AutomaticSize = Enum.AutomaticSize.X
        pillBg.Position = UDim2.new(1,-24,0.5,-9); pillBg.BackgroundColor3 = Color3.fromRGB(255,210,225); pillBg.BackgroundTransparency = 0.2
        Instance.new("UICorner", pillBg).CornerRadius = UDim.new(1,0)
        local pillPad = Instance.new("UIPadding", pillBg); pillPad.PaddingLeft = UDim.new(0,6); pillPad.PaddingRight = UDim.new(0,6)
        local valLbl = Instance.new("TextLabel", pillBg)
        valLbl.Size = UDim2.new(0,0,1,0); valLbl.AutomaticSize = Enum.AutomaticSize.X
        valLbl.Text = selected; valLbl.Font = Enum.Font.GothamBold; valLbl.TextColor3 = DarkPink; valLbl.TextSize = 8; valLbl.BackgroundTransparency = 1
        task.defer(function() pillBg.Position = UDim2.new(1,-(pillBg.AbsoluteSize.X+22),0.5,-9) end)
        local arrow = Instance.new("TextLabel", head)
        arrow.Size = UDim2.new(0,16,1,0); arrow.Position = UDim2.new(1,-18,0,0)
        arrow.Text = "V"; arrow.Font = Enum.Font.GothamBold; arrow.TextColor3 = DarkPink; arrow.TextSize = 9; arrow.BackgroundTransparency = 1
        local PINK_LIGHT  = Color3.fromRGB(255,240,246)
        local PINK_SELECT = Color3.fromRGB(255,215,230)

        local listFrame = Instance.new("ScrollingFrame", main)
        listFrame.BackgroundColor3 = PINK_LIGHT
        listFrame.BackgroundTransparency = 0
        listFrame.BorderSizePixel = 0
        listFrame.Visible = false; listFrame.ZIndex = 50; listFrame.ClipsDescendants = true
        listFrame.ScrollBarThickness = 2; listFrame.ScrollBarImageColor3 = DarkPink
        listFrame.CanvasSize = UDim2.new(0,0,0,0); listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        listFrame.ScrollingDirection = Enum.ScrollingDirection.Y; listFrame.ElasticBehavior = Enum.ElasticBehavior.Never
        Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0,8)
        local listStroke = Instance.new("UIStroke", listFrame)
        listStroke.Color = DarkPink; listStroke.Thickness = 1.0; listStroke.Transparency = 0.5

        local function CloseList(instant)
            if not isOpen then return end; isOpen = false; activeDropdown = nil
            TweenService:Create(arrow, TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Rotation=0}):Play()
            TweenService:Create(headStroke, TweenInfo.new(0.15), {Transparency=0}):Play()
            listFrame.Visible = false
        end

        local function OpenList()
            if activeDropdown and activeDropdown ~= CloseList then activeDropdown(true) end
            activeDropdown = CloseList; isOpen = true
            local absPos = head.AbsolutePosition; local absSize = head.AbsoluteSize
            local totalH = #options * ITEM_H + 6; local listW = absSize.X

            -- Xóa item cũ
            for _, c in pairs(listFrame:GetChildren()) do
                if c:IsA("TextButton") or c:IsA("Frame") then c:Destroy() end
            end

            -- Padding trên
            local padTop = Instance.new("Frame", listFrame)
            padTop.Size = UDim2.new(1,0,0,3); padTop.BackgroundTransparency = 1

            for i, opt in ipairs(options) do
                local isSel = opt == selected
                local item = Instance.new("TextButton", listFrame)
                item.Size = UDim2.new(1,-8,0,ITEM_H)
                item.Position = UDim2.new(0,4,0,(i-1)*ITEM_H+3)
                item.BackgroundColor3 = isSel and PINK_SELECT or PINK_LIGHT
                item.BackgroundTransparency = isSel and 0 or 1
                item.BorderSizePixel = 0
                item.Text = ""; item.ZIndex = 51
                Instance.new("UICorner", item).CornerRadius = UDim.new(0,6)

                -- Checkmark
                local chk = Instance.new("TextLabel", item)
                chk.Size = UDim2.new(0,16,1,0); chk.Position = UDim2.new(0,4,0,0)
                chk.Text = isSel and "✓" or ""
                chk.Font = Enum.Font.GothamBold; chk.TextSize = 8
                chk.TextColor3 = DarkPink; chk.BackgroundTransparency = 1; chk.ZIndex = 52

                -- Text
                local txt = Instance.new("TextLabel", item)
                txt.Size = UDim2.new(1,-20,1,0); txt.Position = UDim2.new(0,20,0,0)
                txt.Text = opt; txt.Font = Enum.Font.GothamBold; txt.TextSize = 9
                txt.TextColor3 = isSel and DarkPink or TextColor
                txt.TextXAlignment = Enum.TextXAlignment.Left
                txt.BackgroundTransparency = 1; txt.ZIndex = 52

                -- Separator (trừ item cuối)
                if i < #options then
                    local sep = Instance.new("Frame", listFrame)
                    sep.Size = UDim2.new(1,-16,0,1)
                    sep.Position = UDim2.new(0,8,0,i*ITEM_H+3)
                    sep.BackgroundColor3 = DarkPink
                    sep.BackgroundTransparency = 0.85
                    sep.BorderSizePixel = 0; sep.ZIndex = 51
                end

                item.MouseEnter:Connect(function()
                    if opt ~= selected then
                        TweenService:Create(item, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(255,228,240), BackgroundTransparency=0}):Play()
                        txt.TextColor3 = DarkPink
                    end
                end)
                item.MouseLeave:Connect(function()
                    if opt ~= selected then
                        TweenService:Create(item, TweenInfo.new(0.1), {BackgroundTransparency=1}):Play()
                        txt.TextColor3 = TextColor
                    end
                end)
                item.MouseButton1Click:Connect(function()
                    PlayClickSound(); selected=opt; S[savedKey]=selected; Save(); valLbl.Text=selected
                    task.defer(function() pillBg.Position = UDim2.new(1,-(pillBg.AbsoluteSize.X+22),0.5,-9) end)
                    CloseList(false)
                    if onCallback then onCallback(selected) end
                    ShowToast("Đã chọn: "..selected, "✅")
                end)
            end

            local mPos = main.AbsolutePosition
            local relY = absPos.Y - mPos.Y + absSize.Y + 4
            local maxH = math.max(40, FRAME_H - relY - 4)
            local clampedH = math.min(totalH, maxH)
            listFrame.Size = UDim2.new(0,listW,0,clampedH)
            listFrame.Position = UDim2.new(0,absPos.X-mPos.X,0,relY)
            listFrame.Visible = true
            TweenService:Create(arrow, TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Rotation=180}):Play()
            TweenService:Create(headStroke, TweenInfo.new(0.15), {Transparency=0.3}):Play()
        end
        local headBtn = Instance.new("TextButton", head)
        headBtn.Size = UDim2.new(1,0,1,0); headBtn.BackgroundTransparency = 1; headBtn.Text = ""; headBtn.ZIndex = 10
        headBtn.MouseButton1Click:Connect(function() PlayClickSound(); if isOpen then CloseList(false) else OpenList() end end)
        headBtn.MouseEnter:Connect(function() TweenService:Create(head, TweenInfo.new(0.15), {BackgroundTransparency=0.25}):Play() end)
        headBtn.MouseLeave:Connect(function() TweenService:Create(head, TweenInfo.new(0.15), {BackgroundTransparency=0.4}):Play() end)
        local function ToggleList() if isOpen then CloseList(false) else OpenList() end end
        return head, ToggleList
    end

    -- ════════════════════════════════════════════
    --  CREATE TAB — resolve Decal tự động + hỗ trợ GitHub asset
    -- ════════════════════════════════════════════
    function Library:CreateTab(name, iconId)
        local page = Instance.new("ScrollingFrame", pages)
        page.Name = name.."Page"; page.Size = UDim2.new(1,0,1,0)
        page.BackgroundTransparency = 1; page.Visible = false
        page.ScrollBarThickness = 0; page.CanvasSize = UDim2.new(0,0,0,0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.ScrollingDirection = Enum.ScrollingDirection.Y
        page.ElasticBehavior = Enum.ElasticBehavior.Never
        page.ScrollingEnabled = true; page.ClipsDescendants = true
        AttachScrollLock(page)

        local tabBtn = Instance.new("ImageButton", sidebar)
        tabBtn.Size = UDim2.new(0,27,0,27)
        tabBtn.BackgroundColor3 = DarkPink
        tabBtn.BackgroundTransparency = 0.2

        -- Nếu iconId là key GitHub asset (vd "IMG:homeIcon") → load từ cache
        -- Ngược lại dùng ResolveImage() như bình thường
        local githubKey = type(iconId) == "string" and iconId:match("^IMG:(.+)$")
        if githubKey then
            tabBtn.Image = GetAsset(githubKey, "")
            -- Async update khi GitHub asset sẵn sàng
            task.spawn(function()
                for _ = 1, 40 do
                    task.wait(0.3)
                    local img = GetAsset(githubKey, "")
                    if img ~= "" then tabBtn.Image = img; break end
                end
            end)
        else
            tabBtn.Image = ResolveImage(tostring(iconId or "0"))
        end

        tabBtn.ScaleType = Enum.ScaleType.Fit
        tabOrder=tabOrder+1; tabBtn.LayoutOrder=tabOrder
        local tabPad = Instance.new("UIPadding", tabBtn)
        tabPad.PaddingTop = UDim.new(0,4); tabPad.PaddingBottom = UDim.new(0,4)
        tabPad.PaddingLeft = UDim.new(0,4); tabPad.PaddingRight = UDim.new(0,4)
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(1,0)
        local tabStroke = Instance.new("UIStroke", tabBtn)
        tabStroke.Color = Color3.new(1,1,1); tabStroke.Thickness = 2
        tabStroke.Transparency = 1; tabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        tabBtn.MouseButton1Click:Connect(function()
            if page.Visible then return end
            PlayClickSound()
            if activeDropdown then activeDropdown(true) end
            -- Đóng GMT dropdown nếu đang mở (tìm và ẩn)
            for _, v in pairs(screenGui:GetChildren()) do
                if v:IsA("Frame") and v.ZIndex == 100 then v.Visible = false end
            end
            for _, v in pairs(pages:GetChildren()) do
                if v:IsA("ScrollingFrame") and v.Visible then
                    TweenService:Create(v, TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Position=UDim2.new(-0.15,0,0,0)}):Play()
                    task.delay(0.18, function() v.Visible=false; v.Position=UDim2.new(0,0,0,0) end)
                end
            end
            for _, b in pairs(sidebar:GetChildren()) do
                if b:IsA("ImageButton") then
                    TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency=0.2}):Play()
                    local s = b:FindFirstChildOfClass("UIStroke")
                    if s then TweenService:Create(s, TweenInfo.new(0.15), {Transparency=1}):Play() end
                end
            end
            task.delay(0.12, function()
                page.Position = UDim2.new(0.15,0,0,0); page.Visible = true
                TweenService:Create(page, TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position=UDim2.new(0,0,0,0)}):Play()
            end)
            TweenService:Create(tabBtn, TweenInfo.new(0.15), {BackgroundTransparency=0}):Play()
            TweenService:Create(tabStroke, TweenInfo.new(0.2), {Transparency=0}):Play()
            -- Bounce lớn hơn khi click tab
            TweenService:Create(tabBtn, TweenInfo.new(0.07,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size=UDim2.new(0,20,0,20)}):Play()
            task.delay(0.07, function()
                TweenService:Create(tabBtn, TweenInfo.new(0.08), {Size=UDim2.new(0,31,0,31)}):Play()
                task.delay(0.08, function()
                    TweenService:Create(tabBtn, TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,27,0,27)}):Play()
                end)
            end)
        end)
        -- Hover float-up
        tabBtn.MouseEnter:Connect(function()
            if not page.Visible then
                TweenService:Create(tabBtn, TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,30,0,30), BackgroundTransparency=0.5}):Play()
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if not page.Visible then
                TweenService:Create(tabBtn, TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size=UDim2.new(0,27,0,27), BackgroundTransparency=0.2}):Play()
            end
        end)

        local yOffset = 4
        local elements = {}

        function elements:AddDashboard()
            local ROW_H=108; local GAP=6; local DASH_H=ROW_H*2+GAP; local row1Y=yOffset
            local userBox=Instance.new("Frame",page); userBox.Size=UDim2.new(0.605,-3,0,ROW_H); userBox.Position=UDim2.new(0,0,0,row1Y)
            userBox.BackgroundColor3=Color3.fromRGB(255,255,255); userBox.BackgroundTransparency=0.55
            Instance.new("UICorner",userBox).CornerRadius=UDim.new(0,10)
            AttachCardGlow(userBox,0,22,1.2)
            do
                local bar=Instance.new("Frame",userBox); bar.Size=UDim2.new(0,18,1,0); bar.BackgroundColor3=DarkPink; bar.BackgroundTransparency=0.2; Instance.new("UICorner",bar).CornerRadius=UDim.new(0,10)
                local lbl=Instance.new("TextLabel",bar); lbl.Size=UDim2.new(1,0,1,0); lbl.Text="P\nL\nA\nY\nE\nR"; lbl.Font=Enum.Font.GothamBold; lbl.TextColor3=Color3.new(1,1,1); lbl.TextSize=7; lbl.TextWrapped=true; lbl.BackgroundTransparency=1
            end
            local pfp=Instance.new("ImageLabel",userBox); pfp.Size=UDim2.new(0,52,0,52); pfp.Position=UDim2.new(0,24,0.5,-26)
            pfp.Image=Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
            pfp.BackgroundTransparency=1; Instance.new("UICorner",pfp).CornerRadius=UDim.new(1,0)
            local g1=Instance.new("TextLabel",userBox); g1.Size=UDim2.new(0.52,0,0.4,0); g1.Position=UDim2.new(0,83,0.08,0); g1.Text="The lanterns light your way~,"; g1.Font=Enum.Font.GothamBold; g1.TextColor3=TextColor; g1.TextSize=8; g1.TextXAlignment=Enum.TextXAlignment.Left; g1.TextWrapped=true; g1.BackgroundTransparency=1
            local g2=Instance.new("TextLabel",userBox); g2.Size=UDim2.new(0.52,0,0.28,0); g2.Position=UDim2.new(0,83,0.44,0); g2.Text=Players.LocalPlayer.DisplayName; g2.Font=Enum.Font.GothamBold; g2.TextColor3=DarkPink; g2.TextSize=13; g2.TextXAlignment=Enum.TextXAlignment.Left; g2.BackgroundTransparency=1
            local g3=Instance.new("TextLabel",userBox); g3.Size=UDim2.new(0.52,0,0.22,0); g3.Position=UDim2.new(0,83,0.74,0); g3.Text="Welcome to TokaiHub"; g3.Font=Enum.Font.Gotham; g3.TextColor3=Color3.fromRGB(160,100,120); g3.TextSize=7; g3.TextXAlignment=Enum.TextXAlignment.Left; g3.BackgroundTransparency=1
            local aboutBox=Instance.new("Frame",page); aboutBox.Size=UDim2.new(0.385,-3,0,ROW_H); aboutBox.Position=UDim2.new(0.615,0,0,row1Y); aboutBox.BackgroundColor3=Color3.fromRGB(255,255,255); aboutBox.BackgroundTransparency=0.55; Instance.new("UICorner",aboutBox).CornerRadius=UDim.new(0,10)
            AttachCardGlow(aboutBox,180,22,1.2)
            do
                local bar=Instance.new("Frame",aboutBox); bar.Size=UDim2.new(0,18,1,0); bar.Position=UDim2.new(1,-18,0,0); bar.BackgroundColor3=DarkPink; bar.BackgroundTransparency=0.2; Instance.new("UICorner",bar).CornerRadius=UDim.new(0,10)
                local lbl=Instance.new("TextLabel",bar); lbl.Size=UDim2.new(1,0,1,0); lbl.Text="A\nB\nO\nU\nT"; lbl.Font=Enum.Font.GothamBold; lbl.TextColor3=Color3.new(1,1,1); lbl.TextSize=7; lbl.TextWrapped=true; lbl.BackgroundTransparency=1
            end
            local ad=Instance.new("TextLabel",aboutBox); ad.Size=UDim2.new(0.82,0,0.52,0); ad.Position=UDim2.new(0.04,0,0.04,0); ad.Text="TokaiHub is a powerful and cute Roblox UI library. Lightweight, draggable, and customizable."; ad.Font=Enum.Font.Gotham; ad.TextColor3=TextColor; ad.TextSize=7; ad.TextWrapped=true; ad.TextXAlignment=Enum.TextXAlignment.Left; ad.BackgroundTransparency=1
            local dcBtn=Instance.new("TextButton",aboutBox); dcBtn.Size=UDim2.new(0.82,0,0.3,0); dcBtn.Position=UDim2.new(0.04,0,0.62,0); dcBtn.BackgroundColor3=Color3.fromRGB(255,255,255); dcBtn.BackgroundTransparency=0.4; dcBtn.Text="💬 discord.gg/nn783R2fK2"; dcBtn.Font=Enum.Font.GothamBold; dcBtn.TextColor3=DarkPink; dcBtn.TextSize=7; Instance.new("UICorner",dcBtn).CornerRadius=UDim.new(0,5)
            dcBtn.MouseButton1Click:Connect(function() PlayClickSound(); SafeCopy(DISCORD); dcBtn.Text="✓ Copied!"; task.delay(2, function() dcBtn.Text="💬 discord.gg/nn783R2fK2" end) end)
            local row2Y=row1Y+ROW_H+GAP
            local clockBox=Instance.new("Frame",page); clockBox.Size=UDim2.new(0.79,-3,0,ROW_H); clockBox.Position=UDim2.new(0,0,0,row2Y); clockBox.BackgroundColor3=Color3.fromRGB(255,255,255); clockBox.BackgroundTransparency=0.55; clockBox.ClipsDescendants=false; Instance.new("UICorner",clockBox).CornerRadius=UDim.new(0,10)
            AttachCardGlow(clockBox,90,22,1.2)
            do
                local bar=Instance.new("Frame",clockBox); bar.Size=UDim2.new(0,18,1,0); bar.BackgroundColor3=DarkPink; bar.BackgroundTransparency=0.2; Instance.new("UICorner",bar).CornerRadius=UDim.new(0,10)
                local lbl=Instance.new("TextLabel",bar); lbl.Size=UDim2.new(1,0,1,0); lbl.Text="T\nI\nM\nE"; lbl.Font=Enum.Font.GothamBold; lbl.TextColor3=Color3.new(1,1,1); lbl.TextSize=7; lbl.TextWrapped=true; lbl.BackgroundTransparency=1
            end
            local timeRow=Instance.new("Frame",clockBox); timeRow.Size=UDim2.new(1,-28,0,28); timeRow.Position=UDim2.new(0,22,0,4); timeRow.BackgroundTransparency=1
            local trl=Instance.new("UIListLayout",timeRow); trl.FillDirection=Enum.FillDirection.Horizontal; trl.VerticalAlignment=Enum.VerticalAlignment.Center; trl.Padding=UDim.new(0,5)
            local timeLabel=Instance.new("TextLabel",timeRow); timeLabel.Size=UDim2.new(0,110,1,0); timeLabel.Font=Enum.Font.GothamBold; timeLabel.TextSize=22; timeLabel.TextColor3=TextColor; timeLabel.BackgroundTransparency=1; timeLabel.TextXAlignment=Enum.TextXAlignment.Left; timeLabel.Text=""
            local ampmBox=Instance.new("Frame",timeRow); ampmBox.Size=UDim2.new(0,24,0,14); ampmBox.BackgroundColor3=DarkPink; Instance.new("UICorner",ampmBox).CornerRadius=UDim.new(0,4)
            local ampmLbl=Instance.new("TextLabel",ampmBox); ampmLbl.Size=UDim2.new(1,0,1,0); ampmLbl.Text="PM"; ampmLbl.TextColor3=Color3.new(1,1,1); ampmLbl.TextSize=8; ampmLbl.Font=Enum.Font.GothamBold; ampmLbl.BackgroundTransparency=1
            local infoRow=Instance.new("Frame",clockBox); infoRow.Size=UDim2.new(1,-28,0,13); infoRow.Position=UDim2.new(0,22,0,34); infoRow.BackgroundTransparency=1
            local il=Instance.new("UIListLayout",infoRow); il.FillDirection=Enum.FillDirection.Horizontal; il.VerticalAlignment=Enum.VerticalAlignment.Center; il.HorizontalAlignment=Enum.HorizontalAlignment.Left; il.Padding=UDim.new(0,4)
            local infoLeft=Instance.new("TextLabel",infoRow); infoLeft.Size=UDim2.new(0,0,1,0); infoLeft.AutomaticSize=Enum.AutomaticSize.X; infoLeft.Text="UTC+8 / GMT+8"; infoLeft.TextSize=7; infoLeft.Font=Enum.Font.Gotham; infoLeft.TextColor3=DarkPink; infoLeft.BackgroundTransparency=1
            local sep=Instance.new("TextLabel",infoRow); sep.Size=UDim2.new(0,0,1,0); sep.AutomaticSize=Enum.AutomaticSize.X; sep.Text="|"; sep.TextSize=7; sep.Font=Enum.Font.Gotham; sep.TextColor3=Color3.fromRGB(200,150,170); sep.BackgroundTransparency=1
            local dateRight=Instance.new("TextLabel",infoRow); dateRight.Size=UDim2.new(0,0,1,0); dateRight.AutomaticSize=Enum.AutomaticSize.X; dateRight.Text=os.date("%A, %B %d"); dateRight.TextSize=7; dateRight.Font=Enum.Font.GothamBold; dateRight.TextColor3=TextColor; dateRight.BackgroundTransparency=1
            local sep2=Instance.new("TextLabel",infoRow); sep2.Size=UDim2.new(0,0,1,0); sep2.AutomaticSize=Enum.AutomaticSize.X; sep2.Text="|"; sep2.TextSize=7; sep2.Font=Enum.Font.Gotham; sep2.TextColor3=Color3.fromRGB(200,150,170); sep2.BackgroundTransparency=1
            local viaInline=Instance.new("TextLabel",infoRow); viaInline.Size=UDim2.new(0,0,1,0); viaInline.AutomaticSize=Enum.AutomaticSize.X; viaInline.RichText=true; viaInline.Text='<font color="rgb(235,110,140)">via </font><b><font color="rgb(90,45,55)">TokaiHub</font></b>'; viaInline.Font=Enum.Font.Gotham; viaInline.TextSize=7; viaInline.BackgroundTransparency=1
            local badgeRow=Instance.new("Frame",clockBox); badgeRow.Size=UDim2.new(1,-28,0,16); badgeRow.Position=UDim2.new(0,22,0,50); badgeRow.BackgroundTransparency=1
            local bl=Instance.new("UIListLayout",badgeRow); bl.FillDirection=Enum.FillDirection.Horizontal; bl.VerticalAlignment=Enum.VerticalAlignment.Center; bl.Padding=UDim.new(0,4)
            local function MakeBadge(par,labelTxt,initVal)
                local pill=Instance.new("Frame",par); pill.Size=UDim2.new(0,0,1,0); pill.AutomaticSize=Enum.AutomaticSize.X; pill.BackgroundColor3=Color3.fromRGB(255,255,255); pill.BackgroundTransparency=0.3; Instance.new("UICorner",pill).CornerRadius=UDim.new(0,5)
                local pad=Instance.new("UIPadding",pill); pad.PaddingLeft=UDim.new(0,4); pad.PaddingRight=UDim.new(0,4)
                local rw=Instance.new("Frame",pill); rw.Size=UDim2.new(1,0,1,0); rw.BackgroundTransparency=1
                local rl=Instance.new("UIListLayout",rw); rl.FillDirection=Enum.FillDirection.Horizontal; rl.VerticalAlignment=Enum.VerticalAlignment.Center; rl.Padding=UDim.new(0,2)
                local lbl=Instance.new("TextLabel",rw); lbl.Size=UDim2.new(0,0,1,0); lbl.AutomaticSize=Enum.AutomaticSize.X; lbl.Text=labelTxt; lbl.Font=Enum.Font.Gotham; lbl.TextSize=7; lbl.TextColor3=DarkPink; lbl.BackgroundTransparency=1
                local vl=Instance.new("TextLabel",rw); vl.Size=UDim2.new(0,0,1,0); vl.AutomaticSize=Enum.AutomaticSize.X; vl.Text=initVal; vl.Font=Enum.Font.GothamBold; vl.TextSize=7; vl.TextColor3=TextColor; vl.BackgroundTransparency=1
                return vl
            end
            local execVal=MakeBadge(badgeRow,"Exec ","1"); local upVal=MakeBadge(badgeRow,"Up ","0m 0s"); local sessVal=MakeBadge(badgeRow,"Sess ","0s")

            -- GMT: dùng đúng MakeDropdown có sẵn, ẩn head, bấm gmtBtn thì trigger
            infoLeft.Visible = false

            -- Tạo dropdown ẩn head, bấm gmtBtn thì toggle
            local gmtHead, gmtToggle = MakeDropdown(page, "GMT Offset", -999, {
                "GMT+0","GMT+1","GMT+2","GMT+3","GMT+4","GMT+5","GMT+6",
                "GMT+7","GMT+8","GMT+9","GMT+10","GMT+11","GMT+12"
            }, "gmtOffsetKey", function(val)
                local offset = tonumber(val:match("GMT%+(%d+)"))
                if offset then gmtOffset = offset end
            end)
            gmtHead.Visible = false  -- ẩn head

            -- Nút GMT trong infoRow
            local gmtBtn = Instance.new("TextButton", infoRow)
            gmtBtn.Size = UDim2.new(0,0,1,0); gmtBtn.AutomaticSize = Enum.AutomaticSize.X
            gmtBtn.BackgroundColor3 = DarkPink; gmtBtn.BackgroundTransparency = 0.55
            gmtBtn.Font = Enum.Font.GothamBold; gmtBtn.TextSize = 7
            gmtBtn.TextColor3 = Color3.new(1,1,1); gmtBtn.ZIndex = 6
            Instance.new("UICorner",gmtBtn).CornerRadius = UDim.new(0,4)
            local gp = Instance.new("UIPadding",gmtBtn)
            gp.PaddingLeft=UDim.new(0,4); gp.PaddingRight=UDim.new(0,4)
            gmtBtn.MouseButton1Click:Connect(function()
                -- Di chuyển head về đúng vị trí gmtBtn trước khi toggle
                local bAbs = gmtBtn.AbsolutePosition
                local pAbs = page.AbsolutePosition
                gmtHead.Position = UDim2.new(0, bAbs.X - pAbs.X - 2, 0, bAbs.Y - pAbs.Y)
                gmtToggle()
            end)

            local statusBox=Instance.new("Frame",page); statusBox.Size=UDim2.new(0.20,-3,0,ROW_H); statusBox.Position=UDim2.new(0.80,0,0,row2Y); statusBox.BackgroundColor3=Color3.fromRGB(255,255,255); statusBox.BackgroundTransparency=0.55; Instance.new("UICorner",statusBox).CornerRadius=UDim.new(0,10)
            AttachCardGlow(statusBox,270,22,1.2)
            do
                local bar=Instance.new("Frame",statusBox); bar.Size=UDim2.new(0,18,1,0); bar.Position=UDim2.new(1,-18,0,0); bar.BackgroundColor3=DarkPink; bar.BackgroundTransparency=0.2; Instance.new("UICorner",bar).CornerRadius=UDim.new(0,10)
                local lbl=Instance.new("TextLabel",bar); lbl.Size=UDim2.new(1,0,1,0); lbl.Text="S\nT\nA\nT\nU\nS"; lbl.Font=Enum.Font.GothamBold; lbl.TextColor3=Color3.new(1,1,1); lbl.TextSize=7; lbl.TextWrapped=true; lbl.BackgroundTransparency=1
            end
            local dotCols={Color3.fromRGB(34,197,94),Color3.fromRGB(34,197,94),Color3.fromRGB(251,146,60),Color3.fromRGB(239,68,68),Color3.fromRGB(107,114,128)}
            for i,col in ipairs(dotCols) do
                local dot=Instance.new("Frame",statusBox); dot.Size=UDim2.new(0,9,0,9); dot.Position=UDim2.new(0.18,0,0,9+(i-1)*18); dot.BackgroundColor3=col; Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
            end
            task.spawn(function()
                local sessStart=os.time()
                while task.wait(1) do
                    local t=os.time()+gmtOffset*3600
                    local h=math.floor(t/3600)%24; local m=math.floor(t/60)%60; local s=t%60
                    local h12=h%12; if h12==0 then h12=12 end
                    local ampm=h>=12 and "PM" or "AM"
                    local days={"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"}
                    local months={"January","February","March","April","May","June","July","August","September","October","November","December"}
                    local wd=math.floor((t/86400+4)%7)+1
                    local y,mo,d=tonumber(os.date("!%Y",t)),tonumber(os.date("!%m",t)),tonumber(os.date("!%d",t))
                    timeLabel.Text=string.format("%02d:%02d:%02d",h12,m,s)
                    ampmLbl.Text=ampm
                    dateRight.Text=days[wd]..", "..months[mo].." "..tostring(d)
                    infoLeft.Text="GMT+"..tostring(gmtOffset)
                    gmtBtn.Text="GMT+"..tostring(gmtOffset)
                    local diff=os.time()-startTime; local sess=os.time()-sessStart
                    execVal.Text=tostring(math.floor(diff/12)%8+1)
                    upVal.Text=string.format("%dm %ds",math.floor(diff/60),diff%60)
                    sessVal.Text=tostring(sess).."s"
                end
            end)
            yOffset = yOffset + DASH_H + 8
        end

        function elements:AddButton(text, callback, toastMsg, toastIcon)
            local capturedY = yOffset  -- capture trước khi yOffset bị cộng
            local btn = MakeAnimButton(page, text, capturedY, callback, toastMsg, toastIcon)
            -- Slide-in từ phải khi thêm vào
            btn.Position = UDim2.new(0.3,2,0,capturedY); btn.BackgroundTransparency = 1
            task.defer(function()
                TweenService:Create(btn, TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position=UDim2.new(0,2,0,capturedY), BackgroundTransparency=0.45}):Play()
            end)
            yOffset = yOffset + 32
        end
        function elements:AddToggle(text, savedKey, callback)
            local capturedY = yOffset  -- capture trước khi yOffset bị cộng
            local tog = MakeToggle(page, text, capturedY, savedKey, callback)
            -- Slide-in từ phải
            tog.Position = UDim2.new(0.3,2,0,capturedY); tog.BackgroundTransparency = 1
            task.defer(function()
                TweenService:Create(tog, TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position=UDim2.new(0,2,0,capturedY), BackgroundTransparency=0.45}):Play()
            end)
            yOffset = yOffset + 30
        end
        -- Button có icon human + tên username bên trái
        function elements:AddUserButton(username, callback, toastMsg)
            local capturedY = yOffset
            local btn = Instance.new("Frame", page)
            btn.Size = UDim2.new(1,-4,0,34); btn.Position = UDim2.new(0,2,0,capturedY)
            btn.BackgroundColor3 = Color3.fromRGB(255,255,255); btn.BackgroundTransparency = 0.45
            btn.ClipsDescendants = true
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,9)
            local stroke = Instance.new("UIStroke", btn); stroke.Color = DarkPink; stroke.Thickness = 1.2
            local iconBg = Instance.new("Frame", btn)
            iconBg.Size = UDim2.new(0,26,0,26); iconBg.Position = UDim2.new(0,4,0.5,-13)
            iconBg.BackgroundColor3 = DarkPink; iconBg.BackgroundTransparency = 0.3
            Instance.new("UICorner", iconBg).CornerRadius = UDim.new(1,0)
            local icon = Instance.new("ImageLabel", iconBg)
            icon.Size = UDim2.new(1,-4,1,-4); icon.Position = UDim2.new(0,2,0,2)
            icon.BackgroundTransparency = 1; icon.ScaleType = Enum.ScaleType.Fit
            icon.Image = GetAsset("humanIcon", "")
            task.spawn(function()
                for _ = 1, 40 do task.wait(0.3)
                    local img = GetAsset("humanIcon", "")
                    if img ~= "" then icon.Image = img; break end
                end
            end)
            local nameLbl = Instance.new("TextLabel", btn)
            nameLbl.Size = UDim2.new(1,-70,1,0); nameLbl.Position = UDim2.new(0,36,0,0)
            nameLbl.Text = username; nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextColor3 = TextColor; nameLbl.TextSize = 10
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.BackgroundTransparency = 1
            -- Nút RUN — chỉ bấm đúng nút mới chạy
            local runBtn = Instance.new("TextButton", btn)
            runBtn.Size = UDim2.new(0,42,0,22); runBtn.Position = UDim2.new(1,-46,0.5,-11)
            runBtn.BackgroundColor3 = DarkPink; runBtn.BackgroundTransparency = 0.1
            runBtn.Text = "▶ RUN"; runBtn.Font = Enum.Font.GothamBold
            runBtn.TextSize = 8; runBtn.TextColor3 = Color3.new(1,1,1); runBtn.ZIndex = 6
            Instance.new("UICorner", runBtn).CornerRadius = UDim.new(0,6)
            runBtn.MouseEnter:Connect(function()
                TweenService:Create(runBtn, TweenInfo.new(0.12), {BackgroundTransparency=0, Size=UDim2.new(0,44,0,24), Position=UDim2.new(1,-47,0.5,-12)}):Play()
            end)
            runBtn.MouseLeave:Connect(function()
                TweenService:Create(runBtn, TweenInfo.new(0.12), {BackgroundTransparency=0.1, Size=UDim2.new(0,42,0,22), Position=UDim2.new(1,-46,0.5,-11)}):Play()
            end)
            runBtn.MouseButton1Click:Connect(function()
                PlayClickSound()
                TweenService:Create(runBtn, TweenInfo.new(0.07), {Size=UDim2.new(0,36,0,18), Position=UDim2.new(1,-43,0.5,-9)}):Play()
                TweenService:Create(stroke, TweenInfo.new(0.07), {Color=Color3.fromRGB(255,80,120), Thickness=2}):Play()
                TweenService:Create(iconBg, TweenInfo.new(0.1,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Rotation=15}):Play()
                task.delay(0.07, function()
                    TweenService:Create(runBtn, TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,42,0,22), Position=UDim2.new(1,-46,0.5,-11)}):Play()
                    TweenService:Create(stroke, TweenInfo.new(0.15), {Color=DarkPink, Thickness=1.2}):Play()
                    TweenService:Create(iconBg, TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Rotation=0}):Play()
                end)
                if toastMsg then ShowToast(toastMsg, "👤") end
                if callback then callback() end
            end)
            btn.Position = UDim2.new(0.3,2,0,capturedY); btn.BackgroundTransparency = 1
            task.defer(function()
                TweenService:Create(btn, TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position=UDim2.new(0,2,0,capturedY), BackgroundTransparency=0.45}):Play()
            end)
            yOffset = yOffset + 38
        end
        function elements:AddSlider(text, min, max, savedKey, suffix, callback)
            MakeSlider(page, text, yOffset, min, max, savedKey, suffix or "", callback); yOffset = yOffset + 44
        end
        function elements:AddDropdown(text, options, savedKey, callback)
            local _h,_t = MakeDropdown(page, text, yOffset, options, savedKey, callback); yOffset = yOffset + 32
        end
        function elements:AddCreation()
            -- card nhỏ gọn: 4 chấm + tên tác giả nhỏ
            local card=Instance.new("Frame",page); card.Size=UDim2.new(1,0,0,26); card.Position=UDim2.new(0,0,0,yOffset); card.BackgroundColor3=Color3.fromRGB(255,255,255); card.BackgroundTransparency=0.55; Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
            local row=Instance.new("Frame",card); row.Size=UDim2.new(1,-10,1,0); row.Position=UDim2.new(0,8,0,0); row.BackgroundTransparency=1
            local rl=Instance.new("UIListLayout",row); rl.FillDirection=Enum.FillDirection.Horizontal; rl.VerticalAlignment=Enum.VerticalAlignment.Center; rl.Padding=UDim.new(0,5)
            -- 4 chấm màu
            local dotColors={Color3.fromRGB(235,110,140),Color3.fromRGB(200,140,220),Color3.fromRGB(140,180,235),Color3.fromRGB(140,220,180)}
            for _,col in ipairs(dotColors) do
                local d=Instance.new("Frame",row); d.Size=UDim2.new(0,5,0,5); d.BackgroundColor3=col; Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
            end
            -- tên nhỏ
            local names=Instance.new("TextLabel",row); names.Size=UDim2.new(0,0,1,0); names.AutomaticSize=Enum.AutomaticSize.X; names.Text="longtokai · zentakt"; names.Font=Enum.Font.Gotham; names.TextColor3=Color3.fromRGB(160,100,120); names.TextSize=8; names.BackgroundTransparency=1
            yOffset = yOffset + 30
        end
        -- Section bar có icon ảnh bên trái
        function elements:AddSectionWithIcon(text, assetKey)
            local capturedY = yOffset
            local bar = Instance.new("Frame", page)
            bar.Size = UDim2.new(1,-4,0,22); bar.Position = UDim2.new(0,2,0,capturedY)
            bar.BackgroundColor3 = Color3.fromRGB(255,255,255); bar.BackgroundTransparency = 0.6
            Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)
            local barStroke = Instance.new("UIStroke", bar); barStroke.Color = DarkPink; barStroke.Thickness = 1; barStroke.Transparency = 0.5
            -- Icon ảnh
            local iconImg = Instance.new("ImageLabel", bar)
            iconImg.Size = UDim2.new(0,16,0,16); iconImg.Position = UDim2.new(0,4,0.5,-8)
            iconImg.BackgroundTransparency = 1; iconImg.ScaleType = Enum.ScaleType.Fit
            iconImg.Image = GetAsset(assetKey, "")
            task.spawn(function()
                for _ = 1, 40 do task.wait(0.3)
                    local img = GetAsset(assetKey, "")
                    if img ~= "" then iconImg.Image = img; break end
                end
            end)
            -- Text
            local lbl = Instance.new("TextLabel", bar)
            lbl.Size = UDim2.new(1,-26,1,0); lbl.Position = UDim2.new(0,24,0,0)
            lbl.Text = text; lbl.Font = Enum.Font.GothamBold; lbl.TextColor3 = DarkPink; lbl.TextSize = 9
            lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.BackgroundTransparency = 1
            -- Slide-in + shimmer
            bar.Position = UDim2.new(-0.2,0,0,capturedY); bar.BackgroundTransparency = 1; lbl.TextTransparency = 1
            task.defer(function()
                TweenService:Create(bar, TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position=UDim2.new(0,2,0,capturedY), BackgroundTransparency=0.6}):Play()
                TweenService:Create(lbl, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {TextTransparency=0}):Play()
            end)
            coroutine.wrap(function()
                local cols = {DarkPink, Color3.fromRGB(200,120,200), Color3.fromRGB(255,140,170), DarkPink}
                local i = 1
                while lbl and lbl.Parent do
                    task.wait(1.2); i = (i % #cols) + 1
                    TweenService:Create(lbl, TweenInfo.new(0.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {TextColor3=cols[i]}):Play()
                end
            end)()
            yOffset = yOffset + 26
        end
        function elements:AddSection(text)
            local capturedY = yOffset
            -- Bar có icon Tokai bên trái
            local bar = Instance.new("Frame", page)
            bar.Size = UDim2.new(1,-4,0,22); bar.Position = UDim2.new(0,2,0,capturedY)
            bar.BackgroundColor3 = Color3.fromRGB(255,255,255); bar.BackgroundTransparency = 0.6
            Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)
            local barStroke = Instance.new("UIStroke", bar)
            barStroke.Color = DarkPink; barStroke.Thickness = 1; barStroke.Transparency = 0.5
            -- Icon Tokai logo
            local iconImg = Instance.new("ImageLabel", bar)
            iconImg.Size = UDim2.new(0,16,0,16); iconImg.Position = UDim2.new(0,4,0.5,-8)
            iconImg.BackgroundTransparency = 1; iconImg.ScaleType = Enum.ScaleType.Fit
            iconImg.Image = GetAsset("homeIcon", "")
            task.spawn(function()
                for _ = 1, 40 do task.wait(0.3)
                    local img = GetAsset("homeIcon", "")
                    if img ~= "" then iconImg.Image = img; break end
                end
            end)
            -- Text
            local lbl = Instance.new("TextLabel", bar)
            lbl.Size = UDim2.new(1,-26,1,0); lbl.Position = UDim2.new(0,24,0,0)
            lbl.Text = text; lbl.Font = Enum.Font.GothamBold; lbl.TextColor3 = DarkPink; lbl.TextSize = 9
            lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.BackgroundTransparency = 1
            -- Slide-in từ trái
            bar.Position = UDim2.new(-0.2,0,0,capturedY); bar.BackgroundTransparency = 1; lbl.TextTransparency = 1
            task.defer(function()
                TweenService:Create(bar, TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position=UDim2.new(0,2,0,capturedY), BackgroundTransparency=0.6}):Play()
                TweenService:Create(lbl, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {TextTransparency=0}):Play()
            end)
            -- Shimmer màu nhịp nhàng
            coroutine.wrap(function()
                local cols = {DarkPink, Color3.fromRGB(200,120,200), Color3.fromRGB(255,140,170), DarkPink}
                local i = 1
                while lbl and lbl.Parent do
                    task.wait(1.2); i = (i % #cols) + 1
                    TweenService:Create(lbl, TweenInfo.new(0.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut), {TextColor3=cols[i]}):Play()
                end
            end)()
            yOffset = yOffset + 26
        end

        if name == "Home" then
            page.Visible = true
            TweenService:Create(tabBtn, TweenInfo.new(0.1), {BackgroundTransparency=0}):Play()
            TweenService:Create(tabStroke, TweenInfo.new(0.2), {Transparency=0}):Play()
        end
        return elements
    end

    task.defer(function()
        task.wait(0.05)
        openBtn.Visible=false; overlay.Visible=true; overlay.BackgroundTransparency=1
        TweenService:Create(overlay, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundTransparency=0.5}):Play()
        main.Visible=true; main.Size=UDim2.new(0,FRAME_W*0.05,0,FRAME_H*0.05); main.BackgroundTransparency=1
        TweenService:Create(main, TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
            {Size=UDim2.new(0,FRAME_W,0,FRAME_H), BackgroundTransparency=0.3}):Play()
    end)

    return Library
end

-- ═══════════════════════════════════════════
--   SETUP
--   · Tab icon dùng Decal/Image ID như cũ
--   · Hoặc dùng "IMG:homeIcon" để load từ GitHub
-- ═══════════════════════════════════════════
local win = Library:CreateWindow()

local homeTab = win:CreateTab("Home", "IMG:tabHome")
homeTab:AddDashboard()
homeTab:AddCreation()

-- ════ SECRET BUTTON ════
local secretPlaying = false
homeTab:AddButton("???", function()
    if secretPlaying then return end

    local Players  = game:GetService("Players")
    local lp       = Players.LocalPlayer
    local CoreGui  = game:GetService("CoreGui")
    local Pink     = Color3.fromRGB(235,110,140)

    -- ══ PASSWORD UI — dùng GetGuiParent + IgnoreGuiInset như overlay gốc ══
    local pGui = Instance.new("ScreenGui")
    pGui.Name = "SecretPass"; pGui.DisplayOrder = 999
    pGui.ResetOnSpawn = false; pGui.IgnoreGuiInset = true
    pGui.Parent = GetGuiParent()

    local pbg = Instance.new("Frame", pGui)
    pbg.Size = UDim2.new(1,0,1,0); pbg.BackgroundColor3 = Color3.new(0,0,0)
    pbg.BackgroundTransparency = 0.45; pbg.ZIndex = 1

    local box = Instance.new("Frame", pGui)
    box.Size = UDim2.new(0,280,0,150); box.Position = UDim2.new(0.5,-140,0.5,-75)
    box.BackgroundColor3 = Color3.fromRGB(18,6,14); box.BackgroundTransparency = 0; box.ZIndex = 2
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,14)
    local bst = Instance.new("UIStroke", box); bst.Color = Pink; bst.Thickness = 1.8

    local title = Instance.new("TextLabel", box)
    title.Size = UDim2.new(1,0,0,38); title.BackgroundTransparency = 1
    title.Text = "⚠️  Enter Password"; title.Font = Enum.Font.GothamBold
    title.TextSize = 13; title.TextColor3 = Pink; title.ZIndex = 3

    local inputBox = Instance.new("TextBox", box)
    inputBox.Size = UDim2.new(1,-20,0,36); inputBox.Position = UDim2.new(0,10,0,42)
    inputBox.BackgroundColor3 = Color3.fromRGB(45,14,28); inputBox.BackgroundTransparency = 0
    inputBox.Font = Enum.Font.Gotham; inputBox.TextSize = 12
    inputBox.TextColor3 = Color3.new(1,1,1); inputBox.PlaceholderText = "Enter password..."
    inputBox.PlaceholderColor3 = Color3.fromRGB(130,80,100)
    inputBox.Text = ""; inputBox.ClearTextOnFocus = true; inputBox.ZIndex = 3
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0,8)

    local confirmBtn = Instance.new("TextButton", box)
    confirmBtn.Size = UDim2.new(0,118,0,30); confirmBtn.Position = UDim2.new(0,10,0,92)
    confirmBtn.BackgroundColor3 = Pink; confirmBtn.BackgroundTransparency = 0.1
    confirmBtn.Text = "Confirm"; confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextSize = 12; confirmBtn.TextColor3 = Color3.new(1,1,1); confirmBtn.ZIndex = 3
    Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0,8)

    local cancelBtn = Instance.new("TextButton", box)
    cancelBtn.Size = UDim2.new(0,118,0,30); cancelBtn.Position = UDim2.new(1,-128,0,92)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(70,25,40); cancelBtn.BackgroundTransparency = 0.1
    cancelBtn.Text = "Cancel"; cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 12; cancelBtn.TextColor3 = Color3.new(1,1,1); cancelBtn.ZIndex = 3
    Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0,8)

    cancelBtn.MouseButton1Click:Connect(function()
        pGui:Destroy()
    end)

    confirmBtn.MouseButton1Click:Connect(function()
        if inputBox.Text ~= "longtokaiaishiteru" then
            title.Text = "❌  Wrong Password"
            title.TextColor3 = Color3.fromRGB(255,70,70)
            inputBox.Text = ""
            task.delay(1.5, function()
                if title and title.Parent then
                    title.Text = "⚠️  Enter Password"
                    title.TextColor3 = Pink
                end
            end)
            return
        end

        -- Xóa password UI ngay lập tức
        pGui:Destroy()
        secretPlaying = true

        -- ══ DARK OVERLAY — y chang overlay gốc nhưng đen hoàn toàn ══
        local darkGui = Instance.new("ScreenGui")
        darkGui.Name = "SecretDark"; darkGui.DisplayOrder = 998
        darkGui.ResetOnSpawn = false; darkGui.IgnoreGuiInset = true
        darkGui.Parent = GetGuiParent()

        local dark = Instance.new("Frame", darkGui)
        dark.Size = UDim2.new(1,0,1,0)
        dark.BackgroundColor3 = Color3.fromRGB(0,0,0)
        dark.BackgroundTransparency = 1; dark.ZIndex = 1
        -- Fade đen hoàn toàn
        TweenService:Create(dark, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency=0}):Play()

        -- Label chữ
        local msgLbl = Instance.new("TextLabel", darkGui)
        msgLbl.Size = UDim2.new(0.85,0,0,70)
        msgLbl.Position = UDim2.new(0.075,0,0.42,0)
        msgLbl.AnchorPoint = Vector2.new(0,0)
        msgLbl.BackgroundTransparency = 1
        msgLbl.TextColor3 = Color3.fromRGB(220,40,40)
        msgLbl.Font = Enum.Font.GothamBold
        msgLbl.TextSize = 22
        msgLbl.TextWrapped = true
        msgLbl.TextTransparency = 1
        msgLbl.Text = ""; msgLbl.ZIndex = 2

        -- Logo góc phải dưới — xoay chậm
        local logoImg = Instance.new("ImageLabel", darkGui)
        logoImg.Size = UDim2.new(0,64,0,64)
        logoImg.Position = UDim2.new(1,-76,1,-76)
        logoImg.AnchorPoint = Vector2.new(0.5,0.5)
        logoImg.BackgroundTransparency = 1
        logoImg.ScaleType = Enum.ScaleType.Fit
        logoImg.ImageTransparency = 0.3
        logoImg.ZIndex = 2
        logoImg.Image = GetAsset("homeIcon","")
        task.spawn(function()
            for _ = 1,60 do
                local img = GetAsset("homeIcon","")
                if img ~= "" then logoImg.Image = img; break end
                task.wait(0.5)
            end
        end)
        -- Xoay chậm
        task.spawn(function()
            local rot = 0
            while logoImg and logoImg.Parent do
                rot = (rot + 2.3) % 360
                logoImg.Rotation = rot
                RunService.Heartbeat:Wait()
            end
        end)

        -- Phát nhạc
        local sound = Instance.new("Sound", workspace)
        sound.Volume = 1

        task.spawn(function()
            -- Phát chuông trước
            local bell = Instance.new("Sound", workspace)
            bell.Volume = 1
            local bs = GetAsset("bellSound","")
            for _ = 1,60 do
                if bs ~= "" then break end
                task.wait(0.5)
                bs = GetAsset("bellSound","")
            end
            bell.SoundId = bs
            bell:Play()
            bell.Ended:Wait()
            game:GetService("Debris"):AddItem(bell, 1)

            -- Rồi mới load và phát nhạc bí mật
            local s = GetAsset("secretSound","")
            for _ = 1,60 do
                if s ~= "" then break end
                task.wait(0.5)
                s = GetAsset("secretSound","")
            end
            sound.SoundId = s
            sound:Play()


            -- Đợi load xong để biết TimeLength
            task.wait(1)
            local totalLen = math.max(sound.TimeLength, 30)
            local loopUntil = totalLen - 14

            -- Chuỗi loop
            local msgs = {
                {t="Don't move.",                                      s=22, dur=3.5},
                {t="Good job.",                                        s=22, dur=3},
                {t="Please stand still and don't move anything.",      s=16, dur=4.5},
                {t="Don't move.",                                      s=22, dur=3.5},
                {t="If you move, it will get worse. Don't move.",      s=16, dur=4.5},
                {t="Don't move.",                                      s=22, dur=3.5},
                {t="LongTokai is coming.",                             s=20, dur=4},
                {t="Don't move.",                                      s=22, dur=3.5},
            }

            local startTick = tick()
            local idx = 1

            while sound.IsPlaying and (tick()-startTick) < loopUntil do
                local m = msgs[idx]
                if msgLbl and msgLbl.Parent then
                    msgLbl.TextSize = m.s
                    msgLbl.Text = m.t
                    msgLbl.TextTransparency = 1
                    TweenService:Create(msgLbl, TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
                        {TextTransparency=0}):Play()
                    task.wait(m.dur - 0.6)
                    TweenService:Create(msgLbl, TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
                        {TextTransparency=1}):Play()
                    task.wait(0.6)
                else break end
                idx = (idx % #msgs) + 1
            end

            -- Ending
            if msgLbl and msgLbl.Parent then
                msgLbl.TextSize = 20
                msgLbl.Text = "You will depart in peace."
                msgLbl.TextTransparency = 1
                TweenService:Create(msgLbl, TweenInfo.new(1), {TextTransparency=0}):Play()
                task.wait(5)
                TweenService:Create(msgLbl, TweenInfo.new(0.5), {TextTransparency=1}):Play()
                task.wait(1)
                msgLbl.TextSize = 22
                msgLbl.Text = "Don't move."
                msgLbl.TextTransparency = 1
                TweenService:Create(msgLbl, TweenInfo.new(0.6), {TextTransparency=0}):Play()
                task.wait(5)
            end

            -- Kick ngay
            lp:Kick("??? | LongTokai got U")
        end)
    end)
end, nil, nil)

local mainTab
local mainTab = win:CreateTab("Main", "IMG:tabMain")
mainTab:AddSection("🔘 Toggle Test")
mainTab:AddToggle("Toggle A", "testToggleA", function(val) print("[Toggle A]", val) end)
mainTab:AddToggle("Toggle B", "testToggleB", function(val) print("[Toggle B]", val) end)
mainTab:AddSection("🎚️ Slider Test")
mainTab:AddSlider("Slider 1 → 10", 1, 10, "testSlider1", "", function(val) print("[Slider 1]", val) end)
mainTab:AddSlider("Slider 0 → 100%", 0, 100, "testSlider2", "%", function(val) print("[Slider 2]", val) end)
mainTab:AddSection("📋 Dropdown Test")
mainTab:AddDropdown("Chọn bộ phận", {"Head","Root","Torso","LeftArm","RightArm"}, "testDrop1", function(val) print("[Dropdown 1]", val) end)
mainTab:AddDropdown("Chọn tùy chọn", {"Option A","Option B","Option C"}, "testDrop2", function(val) print("[Dropdown 2]", val) end)
mainTab:AddSection("🎮 Button Test")
mainTab:AddButton("▶ Chạy Test", function() print("[Button] Đã nhấn!") end, "Test thành công!", "✅")

local uselessTab = win:CreateTab("Useless", "7743875630")
uselessTab:AddSectionWithIcon("Random Scripts", "gunIcon")
uselessTab:AddUserButton("wklbox", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/longhazem/TOKAIHUB/refs/heads/main/Test"))()
end, "Đang chạy script: wklbox")
uselessTab:AddUserButton("dolboeb228_negr", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/longhazem/TOKAIHUB/refs/heads/main/Audio"))()
end, "Đang chạy script: dolboeb228_negr")

-- ════ SETTINGS TAB ════
local settingsTab = win:CreateTab("Settings", "IMG:tabSettings")
settingsTab:AddSection("ℹ️ Info")

return lib
