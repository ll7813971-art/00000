--[[
	=====================================================================
	  SUPER OBBY PRO  —  generador automático de Obby para Roblox Studio
	=====================================================================

	CÓMO USARLO
	  1. En Roblox Studio, en el Explorador, haz clic derecho en
	     ServerScriptService > Insert Object > Script (un Script normal,
	     NO un LocalScript ni un ModuleScript).
	  2. Borra lo que trae y pega TODO este archivo.
	  3. Dale a Play. El obby se construye solo dentro de una carpeta
	     "SuperObby" en Workspace (si ya existía, se reconstruye).

	QUÉ INCLUYE (15 etapas + meta)
	  Saltos clásicos, piso de lava, plataformas móviles y ascensor,
	  aspas giratorias, bloques que desaparecen, cintas transportadoras,
	  trampolines, cuerda floja, torre de escalada, pasillo láser,
	  péndulos, pista de hielo, súper velocidad, "¿cuál es real?" y una
	  espiral al cielo. Al final hay una meta con trofeo, confeti y una
	  plataforma para volver a empezar.

	  Además: checkpoints con anti-salto, leaderstats (Etapa / Victorias),
	  HUD con barra de progreso y avisos, cronómetro con récord personal,
	  guardado del progreso con DataStore y un "vacío" que te reinicia si
	  te caes.

	GUARDADO (DataStore)
	  Para que se guarde el progreso al probar en Studio, activa:
	  Game Settings > Security > "Enable Studio Access to API Services".
	  (El juego tiene que estar publicado.) Si no está activado, el obby
	  funciona igual, solo que no guarda.

	Todo lo ajustable está en CONFIG, justo aquí abajo.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local StarterPlayer = game:GetService("StarterPlayer")

---------------------------------------------------------------------
-- CONFIGURACIÓN
---------------------------------------------------------------------
local CONFIG = {
	NombreCarpeta = "SuperObby",
	Inicio = Vector3.new(0, 60, 0),      -- dónde empieza el obby
	Semilla = 2026,                      -- cambia el número para otro diseño aleatorio
	AntiSalto = true,                    -- no puedes saltarte checkpoints
	TiempoReaparicion = 1.5,             -- segundos para reaparecer al morir
	ProfundidadVacio = 35,               -- a cuántos studs bajo el inicio está el vacío mortal
	GuardarProgreso = true,
	NombreDataStore = "SuperObby_Progreso_v1",
	AutoGuardado = 120,                  -- segundos entre guardados automáticos
	MejorarIluminacion = true,           -- añade Bloom y un poco de saturación
}

local WALK_SPEED = StarterPlayer.CharacterWalkSpeed
local rng = Random.new(CONFIG.Semilla)

local WHITE = Color3.fromRGB(255, 255, 255)
local DARK = Color3.fromRGB(45, 45, 55)
local RED = Color3.fromRGB(255, 45, 45)
local GOLD = Color3.fromRGB(255, 200, 40)
local GREEN = Color3.fromRGB(80, 255, 120)
local LAVA = Color3.fromRGB(255, 95, 20)

---------------------------------------------------------------------
-- ESTADO
---------------------------------------------------------------------
local obbyFolder: Folder
local currentFolder: Instance

local checkpoints = {}   -- [etapa] = Part
local stageNames = {}    -- [etapa] = nombre
local TOTAL = 0

local movers = {}        -- plataformas movidas por AlignPosition
local pendulums = {}
local decor = {}
local laserGates = {}
local hazards = {}       -- partes mortales que además se revisan por zona

local profiles = {}      -- [player] = datos de sesión
local huds = {}          -- [player] = referencias del HUD

local reachStage         -- se define más abajo

---------------------------------------------------------------------
-- UTILIDADES DE CONSTRUCCIÓN
---------------------------------------------------------------------
local function part(props)
	local p = Instance.new(props.ClassName or "Part")
	p.Anchored = true
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in pairs(props) do
		if key ~= "Parent" and key ~= "ClassName" then
			p[key] = value
		end
	end
	p.Parent = props.Parent or currentFolder
	return p
end

-- Plataforma sencilla: centro, tamaño, color y material opcional
local function plat(center: Vector3, size: Vector3, color: Color3, material: Enum.Material?)
	return part({
		Size = size,
		CFrame = CFrame.new(center),
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
	})
end

-- Parte puramente decorativa (no choca, no se toca, no se detecta)
local function deco(props)
	props.CanCollide = false
	props.CanTouch = false
	props.CanQuery = false
	props.CastShadow = false
	return part(props)
end

local function billboard(adornee: BasePart, text: string, color: Color3, offsetY: number, width: number?, height: number?)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(width or 12, 0, height or 3, 0)
	bb.StudsOffset = Vector3.new(0, offsetY, 0)
	bb.MaxDistance = 150
	bb.LightInfluence = 0
	bb.Adornee = adornee

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.TextColor3 = color
	label.TextStrokeTransparency = 0.2
	label.Parent = bb

	bb.Parent = adornee
	return bb
end

local function themeFor(index: number, count: number)
	local h = (index - 1) / count
	return {
		main = Color3.fromHSV(h, 0.55, 0.95),
		alt = Color3.fromHSV((h + 0.07) % 1, 0.4, 1),
		accent = Color3.fromHSV((h + 0.5) % 1, 0.8, 1),
		checkpoint = Color3.fromHSV(h, 0.2, 1),
	}
end

---------------------------------------------------------------------
-- JUGADORES: utilidades
---------------------------------------------------------------------
-- Devuelve (player, character, humanoid) si la parte tocada es de un jugador vivo
local function characterFromHit(hit: BasePart)
	local model = hit:FindFirstAncestorOfClass("Model")
	while model and not Players:GetPlayerFromCharacter(model) do
		model = model:FindFirstAncestorOfClass("Model")
	end
	if not model then
		return nil
	end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return nil
	end
	return Players:GetPlayerFromCharacter(model), model, humanoid
end

local function killHit(hit: BasePart)
	local _, _, humanoid = characterFromHit(hit)
	if humanoid then
		humanoid.Health = 0
	end
end

local function getStage(player: Player): (number, IntValue?)
	local stats = player:FindFirstChild("leaderstats")
	local value = stats and stats:FindFirstChild("Etapa")
	if value then
		return value.Value, value
	end
	return 1, nil
end

local function formatTime(seconds: number): string
	return string.format("%d:%05.2f", math.floor(seconds / 60), seconds % 60)
end

---------------------------------------------------------------------
-- HUD (se crea desde el servidor, no hace falta LocalScript)
---------------------------------------------------------------------
local function corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function updateHud(player: Player)
	local hud = huds[player]
	if not hud then
		return
	end
	local stage = getStage(player)
	hud.title.Text = string.format("Etapa %d / %d", stage, TOTAL)
	hud.sub.Text = stageNames[stage] or ""
	local progress = if TOTAL > 1 then (stage - 1) / (TOTAL - 1) else 1
	hud.fill.Size = UDim2.fromScale(math.clamp(progress, 0, 1), 1)
end

local function notify(player: Player, text: string, color: Color3?, duration: number?)
	local hud = huds[player]
	if not hud then
		return
	end
	hud.token += 1
	local token = hud.token
	hud.toast.Text = text
	hud.toast.TextColor3 = color or WHITE
	hud.toast.Visible = true
	task.delay(duration or 2.5, function()
		if hud.token == token and hud.toast.Parent then
			hud.toast.Visible = false
		end
	end)
end

local function notifyAll(text: string, color: Color3?, duration: number?)
	for _, player in ipairs(Players:GetPlayers()) do
		notify(player, text, color, duration)
	end
end

local function buildHud(player: Player)
	local playerGui = player:WaitForChild("PlayerGui", 20)
	if not playerGui or not player.Parent then
		return
	end
	local old = playerGui:FindFirstChild("ObbyHUD")
	if old then
		old:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "ObbyHUD"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0)
	panel.Position = UDim2.new(0.5, 0, 0, 8)
	panel.Size = UDim2.fromOffset(280, 64)
	panel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	panel.BackgroundTransparency = 0.2
	panel.Parent = gui
	corner(panel, 12)
	local stroke = Instance.new("UIStroke")
	stroke.Color = GOLD
	stroke.Thickness = 2
	stroke.Parent = panel

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(10, 5)
	title.Size = UDim2.new(1, -20, 0, 26)
	title.Font = Enum.Font.FredokaOne
	title.TextScaled = true
	title.TextColor3 = WHITE
	title.Parent = panel

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.fromOffset(10, 31)
	sub.Size = UDim2.new(1, -20, 0, 16)
	sub.Font = Enum.Font.GothamMedium
	sub.TextScaled = true
	sub.TextColor3 = Color3.fromRGB(200, 200, 215)
	sub.Parent = panel

	local barBack = Instance.new("Frame")
	barBack.Position = UDim2.new(0, 10, 1, -12)
	barBack.Size = UDim2.new(1, -20, 0, 6)
	barBack.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
	barBack.BorderSizePixel = 0
	barBack.Parent = panel
	corner(barBack, 3)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = GREEN
	fill.BorderSizePixel = 0
	fill.Parent = barBack
	corner(fill, 3)

	local toast = Instance.new("TextLabel")
	toast.AnchorPoint = Vector2.new(0.5, 0)
	toast.Position = UDim2.new(0.5, 0, 0, 80)
	toast.Size = UDim2.new(0.7, 0, 0, 40)
	toast.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	toast.BackgroundTransparency = 0.25
	toast.Font = Enum.Font.FredokaOne
	toast.TextScaled = true
	toast.TextStrokeTransparency = 0.4
	toast.Visible = false
	toast.Parent = gui
	corner(toast, 10)
	local toastLimit = Instance.new("UISizeConstraint")
	toastLimit.MaxSize = Vector2.new(560, 40)
	toastLimit.Parent = toast

	huds[player] = { title = title, sub = sub, fill = fill, toast = toast, token = 0 }
	gui.Parent = playerGui
	updateHud(player)
end

---------------------------------------------------------------------
-- MECÁNICAS
---------------------------------------------------------------------
-- Parte mortal. scan = true (o una función que diga si está activa)
-- hace que además se revise por zona cada 0.1 s, para objetos que se
-- mueven y a veces no disparan Touched.
local function makeKill(p: BasePart, scan: any?)
	p:SetAttribute("Mortal", true)
	p.Touched:Connect(killHit)
	if scan then
		table.insert(hazards, { part = p, active = if type(scan) == "function" then scan else nil })
	end
	return p
end

-- Plataforma que se mueve con física (lleva al jugador encima)
local function makeMover(center: Vector3, size: Vector3, offset: Vector3, period: number, phase: number, color: Color3)
	local p = part({
		Name = "PlataformaMovil",
		Size = size,
		CFrame = CFrame.new(center),
		Anchored = false,
		Color = color,
		Material = Enum.Material.Metal,
		CustomPhysicalProperties = PhysicalProperties.new(2, 1, 0, 100, 1),
	})
	local attachment = Instance.new("Attachment")
	attachment.Parent = p

	local alignPos = Instance.new("AlignPosition")
	alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPos.Attachment0 = attachment
	alignPos.RigidityEnabled = true
	alignPos.Position = center
	alignPos.Parent = p

	local alignRot = Instance.new("AlignOrientation")
	alignRot.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignRot.Attachment0 = attachment
	alignRot.RigidityEnabled = true
	alignRot.CFrame = CFrame.new()
	alignRot.Parent = p

	-- franjas brillantes para que se vea que se mueve
	for _, side in ipairs({ -1, 1 }) do
		local stripe = deco({
			Name = "Brillo",
			Size = Vector3.new(size.X, 0.3, 0.4),
			CFrame = CFrame.new(center + Vector3.new(0, size.Y / 2, side * (size.Z / 2 - 0.2))),
			Anchored = false,
			Massless = true,
			Color = WHITE,
			Material = Enum.Material.Neon,
		})
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = p
		weld.Part1 = stripe
		weld.Parent = p
	end

	pcall(function()
		p:SetNetworkOwner(nil) -- el servidor controla la física: más estable
	end)

	table.insert(movers, {
		align = alignPos,
		origin = center,
		offset = offset,
		w = 2 * math.pi / period,
		phase = phase,
	})
	return p
end

-- Aspa giratoria mortal sobre un eje (HingeConstraint en modo motor)
local function makeSpinner(base: Vector3, length: number, speed: number, arms: number)
	local center = base + Vector3.new(0, 1.6, 0)
	local axis = CFrame.new(center) * CFrame.Angles(0, 0, math.pi / 2) -- eje X -> vertical

	local hub = part({
		Name = "Eje",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(3.2, 2.4, 2.4),
		CFrame = axis,
		Color = DARK,
		Material = Enum.Material.Metal,
	})

	local bar = part({
		Name = "Aspa",
		Size = Vector3.new(length, 0.8, 0.8),
		CFrame = CFrame.new(center),
		Anchored = false,
		CanCollide = false,
		Color = RED,
		Material = Enum.Material.Neon,
	})
	makeKill(bar, true)

	if arms >= 2 then
		local bar2 = part({
			Name = "Aspa",
			Size = Vector3.new(0.8, 0.8, length),
			CFrame = CFrame.new(center),
			Anchored = false,
			CanCollide = false,
			Color = RED,
			Material = Enum.Material.Neon,
		})
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = bar
		weld.Part1 = bar2
		weld.Parent = bar
		makeKill(bar2, true)
	end

	local a0 = Instance.new("Attachment")
	a0.CFrame = hub.CFrame:ToObjectSpace(axis)
	a0.Parent = hub
	local a1 = Instance.new("Attachment")
	a1.CFrame = bar.CFrame:ToObjectSpace(axis)
	a1.Parent = bar

	local hinge = Instance.new("HingeConstraint")
	hinge.Attachment0 = a0
	hinge.Attachment1 = a1
	hinge.ActuatorType = Enum.ActuatorType.Motor
	hinge.AngularVelocity = speed
	hinge.MotorMaxTorque = 1e9
	hinge.Parent = hub

	pcall(function()
		bar:SetNetworkOwner(nil)
	end)
end

-- Bloque que parpadea y desaparece al pisarlo, luego vuelve
local function makeVanishing(p: BasePart)
	local baseTransparency = p.Transparency
	local busy = false
	p.Touched:Connect(function(hit)
		if busy or not characterFromHit(hit) then
			return
		end
		busy = true
		task.spawn(function()
			for _ = 1, 4 do
				p.Transparency = 0.6
				task.wait(0.1)
				p.Transparency = baseTransparency
				task.wait(0.1)
			end
			p.Transparency = 1
			p.CanCollide = false
			task.wait(2.5)
			p.CanCollide = true
			p.Transparency = baseTransparency
			busy = false
		end)
	end)
end

-- Impulso hacia arriba. Se usa un LinearVelocity (se replica al cliente,
-- que es quien simula al personaje) durante un instante.
local function launch(character: Model, power: number)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local attachment = root:FindFirstChild("RootAttachment")
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "RootAttachment"
		attachment.Parent = root
	end
	local old = root:FindFirstChild("ObbyImpulso")
	if old then
		old:Destroy()
	end
	local lv = Instance.new("LinearVelocity")
	lv.Name = "ObbyImpulso"
	lv.Attachment0 = attachment
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
	lv.LineDirection = Vector3.yAxis
	lv.LineVelocity = power
	lv.MaxForce = 1e7
	lv.Parent = root
	Debris:AddItem(lv, 0.15)
end

local function makeJumpPad(pad: BasePart, power: number)
	pad.Touched:Connect(function(hit)
		local _, character = characterFromHit(hit)
		if not character then
			return
		end
		local last = character:GetAttribute("UltimoTrampolin") or 0
		if os.clock() - last < 0.6 then
			return
		end
		character:SetAttribute("UltimoTrampolin", os.clock())
		launch(character, power)
	end)
end

local function makeSpeedPad(p: BasePart, speed: number, duration: number)
	p.Touched:Connect(function(hit)
		local _, _, humanoid = characterFromHit(hit)
		if not humanoid then
			return
		end
		local last = humanoid:GetAttribute("VelocidadEn") or 0
		if os.clock() - last < 0.3 then
			return
		end
		local token = (humanoid:GetAttribute("VelocidadToken") or 0) + 1
		humanoid:SetAttribute("VelocidadEn", os.clock())
		humanoid:SetAttribute("VelocidadToken", token)
		humanoid.WalkSpeed = speed
		task.delay(duration, function()
			if humanoid.Parent and humanoid:GetAttribute("VelocidadToken") == token then
				humanoid.WalkSpeed = WALK_SPEED
			end
		end)
	end)
end

local function makePendulum(pivot: Vector3, length: number, ballSize: number, ampDeg: number, period: number, phase: number, color: Color3)
	local rope = deco({
		Name = "Cadena",
		Size = Vector3.new(0.4, length, 0.4),
		CFrame = CFrame.new(pivot - Vector3.new(0, length / 2, 0)),
		Color = Color3.fromRGB(70, 70, 80),
		Material = Enum.Material.Metal,
	})
	local ball = part({
		Name = "Bola",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(ballSize, ballSize, ballSize),
		CFrame = CFrame.new(pivot - Vector3.new(0, length, 0)),
		CanCollide = false,
		Color = color,
		Material = Enum.Material.Neon,
	})
	makeKill(ball, true)
	table.insert(pendulums, {
		pivot = CFrame.new(pivot),
		rope = rope,
		ball = ball,
		length = length,
		amp = math.rad(ampDeg),
		w = 2 * math.pi / period,
		phase = phase,
	})
end

local function makeLaserGate(base: Vector3, width: number, period: number, onTime: number, phase: number)
	local gate = { beams = {}, period = period, onTime = onTime, phase = phase, on = true }
	for _, h in ipairs({ 0.8, 2.6, 4.4, 6.2 }) do
		local beam = part({
			Name = "Laser",
			Size = Vector3.new(width, 0.3, 0.3),
			CFrame = CFrame.new(base + Vector3.new(0, h, 0)),
			CanCollide = false,
			Color = RED,
			Material = Enum.Material.Neon,
		})
		makeKill(beam, function()
			return gate.on
		end)
		table.insert(gate.beams, beam)
	end
	for _, side in ipairs({ -1, 1 }) do
		part({
			Name = "Emisor",
			Size = Vector3.new(1, 7.5, 1),
			CFrame = CFrame.new(base + Vector3.new(side * (width / 2 + 0.5), 3.75, 0)),
			Color = DARK,
			Material = Enum.Material.Metal,
		})
	end
	table.insert(laserGates, gate)
end

-- Flecha decorativa (para las cintas transportadoras)
local function arrow(center: Vector3, dir: Vector3, color: Color3)
	local base = CFrame.lookAt(center, center + dir.Unit)
	for _, side in ipairs({ -1, 1 }) do
		deco({
			Name = "Flecha",
			Size = Vector3.new(0.4, 0.1, 2.4),
			CFrame = base * CFrame.Angles(0, side * math.rad(40), 0) * CFrame.new(0, 0, 1.2),
			Color = color,
			Material = Enum.Material.Neon,
		})
	end
end

local function addDecor(position: Vector3, color: Color3)
	local p = deco({
		Name = "Decoracion",
		Size = Vector3.new(3, 3, 3),
		CFrame = CFrame.new(position),
		Color = color,
		Material = Enum.Material.Neon,
		Transparency = 0.15,
	})
	table.insert(decor, {
		part = p,
		base = position,
		spin = rng:NextNumber(0.4, 1.2),
		bob = rng:NextNumber(0, math.pi * 2),
	})
end

---------------------------------------------------------------------
-- CHECKPOINTS
---------------------------------------------------------------------
-- origin = punto en la superficie, en el borde de entrada del checkpoint
local function makeCheckpoint(stage: number, origin: Vector3, theme, label: string)
	local isSpawn = stage == 1
	local pad = part({
		ClassName = if isSpawn then "SpawnLocation" else "Part",
		Name = "Checkpoint_" .. stage,
		Size = Vector3.new(12, 1, 12),
		-- girado 180° para que al reaparecer mires hacia delante (+Z)
		CFrame = CFrame.new(origin + Vector3.new(0, -0.5, 6)) * CFrame.Angles(0, math.pi, 0),
		Color = theme.checkpoint,
	})
	if isSpawn then
		pad.Neutral = true
		pad.Duration = 0
		pad.AllowTeamChangeOnTouch = false
	end
	pad:SetAttribute("Etapa", stage)

	deco({
		Name = "Brillo",
		Size = Vector3.new(8, 0.1, 8),
		CFrame = CFrame.new(origin + Vector3.new(0, 0.05, 6)),
		Color = theme.accent,
		Material = Enum.Material.Neon,
		Transparency = 0.35,
	})
	billboard(pad, string.format("ETAPA %d\n%s", stage, label), WHITE, 7, 14, 4)

	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0, 1, 0)
	attachment.Parent = pad
	local burst = Instance.new("ParticleEmitter")
	burst.Name = "Explosion"
	burst.Rate = 0
	burst.Speed = NumberRange.new(10, 20)
	burst.SpreadAngle = Vector2.new(70, 70)
	burst.Lifetime = NumberRange.new(0.8, 1.4)
	burst.Color = ColorSequence.new(theme.main, theme.accent)
	burst.Size = NumberSequence.new(0.7, 0)
	burst.Acceleration = Vector3.new(0, -30, 0)
	burst.LightEmission = 0.6
	burst.Parent = attachment

	local sound = Instance.new("Sound")
	sound.Name = "Ding"
	sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
	sound.Volume = 0.6
	sound.Parent = pad

	pad.Touched:Connect(function(hit)
		local player = characterFromHit(hit)
		if player then
			reachStage(player, stage)
		end
	end)

	checkpoints[stage] = pad
	stageNames[stage] = label
	return pad
end

---------------------------------------------------------------------
-- SECCIONES
-- Cada una recibe o (punto en la superficie donde empieza, centrado en X)
-- y devuelve el punto donde empieza el siguiente checkpoint.
---------------------------------------------------------------------
local function secJumps(o: Vector3, th)
	local y, z = o.Y, o.Z
	for i = 1, 7 do
		y += 1.5
		z += 4
		local x = o.X + (if i % 2 == 0 then 4 else -4)
		local size = if i % 3 == 0 then Vector3.new(4, 1, 4) else Vector3.new(6, 1, 6)
		plat(Vector3.new(x, y - 0.5, z + size.Z / 2), size, if i % 2 == 0 then th.alt else th.main)
		z += size.Z
	end
	return Vector3.new(o.X, y, z + 4)
end

local function secLava(o: Vector3, th)
	local y, z = o.Y, o.Z
	for _ = 1, 9 do
		z += 3.5
		local x = o.X + rng:NextNumber(-4, 4)
		plat(Vector3.new(x, y - 0.5, z + 2), Vector3.new(4, 1, 4), th.main, Enum.Material.Basalt)
		z += 4
	end
	z += 4
	makeKill(part({
		Name = "Lava",
		Size = Vector3.new(30, 1, z - o.Z),
		CFrame = CFrame.new(o.X, y - 3.5, (o.Z + z) / 2),
		Color = LAVA,
		Material = Enum.Material.CrackedLava,
	}))
	return Vector3.new(o.X, y, z)
end

local function secMovers(o: Vector3, th)
	local y, z = o.Y, o.Z
	for i = 1, 3 do
		z += 4
		makeMover(Vector3.new(o.X, y - 0.5, z + 3.5), Vector3.new(7, 1, 7), Vector3.new(10, 0, 0), 6, (i - 1) * 0.6, th.main)
		z += 7
	end
	-- ascensor: sube y baja 12 studs
	z += 4
	makeMover(Vector3.new(o.X, y + 5.5, z + 3.5), Vector3.new(7, 1, 7), Vector3.new(0, 6, 0), 7, 0, th.accent)
	z += 7
	return Vector3.new(o.X, y + 12, z + 4)
end

local function secSpinners(o: Vector3, th)
	local y, z = o.Y, o.Z
	local length = 60
	plat(Vector3.new(o.X, y - 0.5, z + length / 2), Vector3.new(14, 1, length), th.main)
	for i = 1, 3 do
		local direction = if i % 2 == 0 then -1 else 1
		makeSpinner(Vector3.new(o.X, y, z + 12 + (i - 1) * 18), 15, direction * (1.4 + i * 0.35), if i == 3 then 2 else 1)
	end
	return Vector3.new(o.X, y, z + length)
end

local function secVanish(o: Vector3, th)
	local y, z = o.Y, o.Z
	for i = 1, 8 do
		z += 3.5
		local x = o.X + math.sin(i * 1.3) * 5
		local p = plat(Vector3.new(x, y - 0.5, z + 3), Vector3.new(6, 1, 6), if i % 2 == 0 then th.alt else th.main, Enum.Material.Glass)
		p.Transparency = 0.1
		makeVanishing(p)
		z += 6
	end
	return Vector3.new(o.X, y, z + 4)
end

local function secConveyor(o: Vector3, th)
	local y, z = o.Y, o.Z
	local pushes = {
		Vector3.new(0, 0, -9),
		Vector3.new(12, 0, 0),
		Vector3.new(0, 0, -11),
		Vector3.new(-12, 0, 0),
		Vector3.new(0, 0, -13),
	}
	local segment = 10
	for i, push in ipairs(pushes) do
		local p = plat(Vector3.new(o.X, y - 0.5, z + segment / 2), Vector3.new(8, 1, segment), if i % 2 == 0 then th.alt else th.main, Enum.Material.DiamondPlate)
		p.Name = "Cinta"
		p.AssemblyLinearVelocity = push -- una parte anclada con velocidad arrastra al jugador
		for _, dz in ipairs({ -2.5, 2.5 }) do
			arrow(Vector3.new(o.X, y + 0.06, z + segment / 2 + dz), push, th.accent)
		end
		z += segment
	end
	makeKill(part({
		Name = "Lava",
		Size = Vector3.new(40, 1, z - o.Z),
		CFrame = CFrame.new(o.X, y - 4, (o.Z + z) / 2),
		Color = LAVA,
		Material = Enum.Material.CrackedLava,
	}))
	return Vector3.new(o.X, y, z)
end

local function secTrampolines(o: Vector3, th)
	local y, z = o.Y, o.Z
	z += 4
	for i = 1, 3 do
		plat(Vector3.new(o.X, y - 0.5, z + 5), Vector3.new(10, 1, 10), if i % 2 == 0 then th.alt else th.main)
		local pad = part({
			Name = "Trampolin",
			Size = Vector3.new(5, 1.2, 5),
			CFrame = CFrame.new(o.X, y - 0.4, z + 5),
			Color = th.accent,
			Material = Enum.Material.Neon,
		})
		makeJumpPad(pad, 70)
		billboard(pad, "⬆", th.accent, 4, 3)
		z += 14
		y += 14
	end
	return Vector3.new(o.X, y, z)
end

local function secTightrope(o: Vector3, th)
	local y = o.Y
	local x, z = o.X, o.Z
	local function beam(a: Vector3, b: Vector3, width: number)
		local mid = (a + b) / 2
		part({
			Name = "Cuerda",
			Size = Vector3.new(width, 1, (b - a).Magnitude),
			CFrame = CFrame.lookAt(mid, b),
			Color = th.alt,
			Material = Enum.Material.Wood,
		})
	end
	for i = 1, 5 do
		local nx = o.X + (if i % 2 == 1 then 7 else -7)
		local nz = z + 11
		beam(Vector3.new(x, y - 0.5, z), Vector3.new(nx, y - 0.5, nz), 1.6 - i * 0.12)
		plat(Vector3.new(nx, y - 0.5, nz), Vector3.new(3, 1, 3), th.accent)
		x, z = nx, nz
	end
	beam(Vector3.new(x, y - 0.5, z), Vector3.new(o.X, y - 0.5, z + 10), 1)
	return Vector3.new(o.X, y, z + 10)
end

local function secTruss(o: Vector3, th)
	local y, z = o.Y, o.Z
	local metal = Color3.fromRGB(150, 150, 165)
	plat(Vector3.new(o.X, y - 0.5, z + 4), Vector3.new(8, 1, 8), th.main)
	part({ ClassName = "TrussPart", Name = "Escalera", Size = Vector3.new(2, 24, 2), CFrame = CFrame.new(o.X, y + 12, z + 9), Color = metal })
	plat(Vector3.new(o.X, y + 23.5, z + 14), Vector3.new(8, 1, 8), th.alt)
	plat(Vector3.new(o.X, y + 23.5, z + 26), Vector3.new(8, 1, 8), th.main)
	part({ ClassName = "TrussPart", Name = "Escalera", Size = Vector3.new(2, 24, 2), CFrame = CFrame.new(o.X, y + 36, z + 31), Color = metal })
	return Vector3.new(o.X, y + 48, z + 32)
end

local function secLasers(o: Vector3, th)
	local y, z = o.Y, o.Z
	local length = 64
	plat(Vector3.new(o.X, y - 0.5, z + length / 2), Vector3.new(12, 1, length), Color3.fromRGB(35, 35, 45), Enum.Material.Metal)
	for i = 1, 7 do
		makeLaserGate(Vector3.new(o.X, y, z + 6 + (i - 1) * 8.5), 12, 3, 1.6, i * 0.45)
	end
	return Vector3.new(o.X, y, z + length)
end

local function secPendulums(o: Vector3, th)
	local y, z = o.Y, o.Z
	local length = 60
	plat(Vector3.new(o.X, y - 0.5, z + length / 2), Vector3.new(8, 1, length), th.main)
	for i = 1, 4 do
		local pz = z + 10 + (i - 1) * 13
		for _, side in ipairs({ -1, 1 }) do
			part({
				Name = "Poste",
				Size = Vector3.new(1.5, 21, 1.5),
				CFrame = CFrame.new(o.X + side * 17, y + 9.5, pz),
				Color = DARK,
				Material = Enum.Material.Metal,
			})
		end
		part({
			Name = "Viga",
			Size = Vector3.new(35.5, 1.5, 1.5),
			CFrame = CFrame.new(o.X, y + 20.25, pz),
			Color = DARK,
			Material = Enum.Material.Metal,
		})
		makePendulum(Vector3.new(o.X, y + 19.5, pz), 15.5, 5, 55, 2.4 + i * 0.25, i * 1.1, th.accent)
	end
	return Vector3.new(o.X, y, z + length)
end

local function secIce(o: Vector3, th)
	local y, z = o.Y, o.Z
	local ice = PhysicalProperties.new(0.9, 0, 0.05, 100, 1)
	for i = 1, 6 do
		z += 3.5
		local side = if i % 2 == 0 then 1 else -1
		part({
			Name = "Hielo",
			Size = Vector3.new(7, 1, 9),
			CFrame = CFrame.new(o.X + side * 3, y - 0.5, z + 4.5) * CFrame.Angles(0, 0, math.rad(12 * side)),
			Color = Color3.fromRGB(170, 225, 255),
			Material = Enum.Material.Ice,
			CustomPhysicalProperties = ice,
		})
		z += 9
	end
	return Vector3.new(o.X, y, z + 4)
end

local function secSpeed(o: Vector3, th)
	local y, z = o.Y, o.Z
	for i = 1, 5 do
		z += if i == 1 then 3 else 11
		local p = plat(Vector3.new(o.X, y - 0.5, z + 6), Vector3.new(8, 1, 12), th.main)
		p.Name = "Turbo"
		makeSpeedPad(p, 34, 5)
		deco({
			Name = "Brillo",
			Size = Vector3.new(2, 0.1, 11),
			CFrame = CFrame.new(o.X, y + 0.05, z + 6),
			Color = Color3.fromRGB(0, 230, 255),
			Material = Enum.Material.Neon,
		})
		z += 12
	end
	return Vector3.new(o.X, y, z + 11)
end

local function secFake(o: Vector3, th)
	local y, z = o.Y, o.Z
	for _ = 1, 6 do
		z += 4
		local real = rng:NextInteger(1, 3)
		for col = 1, 3 do
			local p = plat(Vector3.new(o.X + (col - 2) * 8, y - 0.5, z + 3), Vector3.new(6, 1, 6), th.alt, Enum.Material.Glass)
			p.Transparency = 0.15
			if col == real then
				p.Name = "Real"
				-- pista sutil: unas pocas chispas
				local hint = Instance.new("ParticleEmitter")
				hint.Rate = 2
				hint.Lifetime = NumberRange.new(1, 1.5)
				hint.Speed = NumberRange.new(0.5, 1)
				hint.Size = NumberSequence.new(0.25, 0)
				hint.LightEmission = 1
				hint.Parent = p
			else
				p.Name = "Falsa"
				p.CanCollide = false
			end
		end
		z += 6
	end
	return Vector3.new(o.X, y, z + 4)
end

local function secSpiral(o: Vector3, th)
	local y = o.Y
	local radius = 10
	local steps = 15 -- 36° por escalón: 15 escalones = 1.5 vueltas
	local center = Vector3.new(o.X, y, o.Z + 18)
	local vertical = CFrame.Angles(0, 0, math.pi / 2)

	part({
		Name = "Pilar",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(48, 10, 10),
		CFrame = CFrame.new(center + Vector3.new(0, 21, 0)) * vertical,
		Color = th.alt,
		Material = Enum.Material.Marble,
	})
	makeKill(part({
		Name = "Lava",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(1, 32, 32),
		CFrame = CFrame.new(center + Vector3.new(0, -4, 0)) * vertical,
		Color = LAVA,
		Material = Enum.Material.CrackedLava,
	}))
	for i = 0, steps do
		part({
			Name = "Escalon",
			Size = Vector3.new(4, 1, 6),
			CFrame = CFrame.new(center) * CFrame.Angles(0, math.rad(36 * i), 0) * CFrame.new(0, i * 3 - 0.5, -radius),
			Color = Color3.fromHSV(i / (steps + 1), 0.6, 1),
		})
	end
	return Vector3.new(o.X, y + steps * 3, center.Z + radius + 3 + 4)
end

local SECTIONS = {
	{ name = "Saltos Clásicos", build = secJumps },
	{ name = "Piso de Lava", build = secLava },
	{ name = "Plataformas Móviles", build = secMovers },
	{ name = "Aspas Giratorias", build = secSpinners },
	{ name = "Bloques que Desaparecen", build = secVanish },
	{ name = "Cintas Locas", build = secConveyor },
	{ name = "Trampolines", build = secTrampolines },
	{ name = "Cuerda Floja", build = secTightrope },
	{ name = "Torre de Escalada", build = secTruss },
	{ name = "Pasillo Láser", build = secLasers },
	{ name = "Péndulos", build = secPendulums },
	{ name = "Pista de Hielo", build = secIce },
	{ name = "Súper Velocidad", build = secSpeed },
	{ name = "¿Cuál es Real?", build = secFake },
	{ name = "Espiral al Cielo", build = secSpiral },
}

---------------------------------------------------------------------
-- META
---------------------------------------------------------------------
local resetPlayer -- se define más abajo

local function buildFinish(o: Vector3, stage: number)
	makeCheckpoint(stage, o, { main = GOLD, alt = GOLD, accent = WHITE, checkpoint = GOLD }, "¡META!")
	local floorCenter = Vector3.new(o.X, o.Y - 0.5, o.Z + 12 + 15)
	plat(floorCenter, Vector3.new(30, 1, 30), Color3.fromRGB(255, 225, 120), Enum.Material.Marble)

	-- trofeo
	local top = o.Y
	local cz = floorCenter.Z
	part({ Name = "Pedestal", Size = Vector3.new(5, 3, 5), CFrame = CFrame.new(o.X, top + 1.5, cz), Color = DARK, Material = Enum.Material.Marble })
	part({ Name = "Trofeo", Size = Vector3.new(1.2, 3, 1.2), CFrame = CFrame.new(o.X, top + 4.5, cz), Color = GOLD, Material = Enum.Material.Neon })
	local cup = part({ Name = "Copa", Shape = Enum.PartType.Ball, Size = Vector3.new(4.5, 4.5, 4.5), CFrame = CFrame.new(o.X, top + 7.5, cz), Color = GOLD, Material = Enum.Material.Neon })
	billboard(cup, "🏆 ¡FELICIDADES! 🏆", GOLD, 5, 20)
	local light = Instance.new("PointLight")
	light.Color = GOLD
	light.Range = 30
	light.Brightness = 2
	light.Parent = cup

	-- confeti en las esquinas
	for _, offset in ipairs({ Vector3.new(-13, 0, -13), Vector3.new(13, 0, -13), Vector3.new(-13, 0, 13), Vector3.new(13, 0, 13) }) do
		local emitterPart = deco({
			Name = "Confeti",
			Size = Vector3.new(1, 1, 1),
			CFrame = CFrame.new(Vector3.new(o.X, top, cz) + offset + Vector3.new(0, 0.5, 0)),
			Transparency = 1,
		})
		local confetti = Instance.new("ParticleEmitter")
		confetti.Rate = 12
		confetti.Lifetime = NumberRange.new(2, 3)
		confetti.Speed = NumberRange.new(25, 35)
		confetti.SpreadAngle = Vector2.new(25, 25)
		confetti.Acceleration = Vector3.new(0, -25, 0)
		confetti.Drag = 1
		confetti.RotSpeed = NumberRange.new(-200, 200)
		confetti.Rotation = NumberRange.new(0, 360)
		confetti.Size = NumberSequence.new(0.5, 0.3)
		confetti.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 70, 70)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 220, 60)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 255, 120)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(70, 160, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 90, 255)),
		})
		confetti.Parent = emitterPart
	end

	-- plataforma para volver a empezar
	local resetPad = part({
		Name = "VolverAEmpezar",
		Size = Vector3.new(6, 1, 6),
		CFrame = CFrame.new(o.X, top - 0.4, cz + 11),
		Color = Color3.fromRGB(170, 80, 255),
		Material = Enum.Material.Neon,
	})
	billboard(resetPad, "🔄 Volver a empezar", WHITE, 4, 12)
	resetPad.Touched:Connect(function(hit)
		local player = characterFromHit(hit)
		if player then
			resetPlayer(player)
		end
	end)
end

---------------------------------------------------------------------
-- CONSTRUCCIÓN COMPLETA
---------------------------------------------------------------------
local function buildObby()
	local old = workspace:FindFirstChild(CONFIG.NombreCarpeta)
	if old then
		old:Destroy()
	end
	obbyFolder = Instance.new("Folder")
	obbyFolder.Name = CONFIG.NombreCarpeta
	obbyFolder.Parent = workspace

	TOTAL = #SECTIONS + 1
	local cursor = CONFIG.Inicio

	for i, section in ipairs(SECTIONS) do
		local theme = themeFor(i, #SECTIONS)
		local folder = Instance.new("Folder")
		folder.Name = string.format("%02d_%s", i, section.name)
		folder.Parent = obbyFolder
		currentFolder = folder

		makeCheckpoint(i, cursor, theme, section.name)
		local startPoint = cursor + Vector3.new(0, 0, 12)
		local endPoint = section.build(startPoint, theme)

		-- cubos flotantes decorativos a los lados
		for _ = 1, 2 do
			local side = if rng:NextNumber() < 0.5 then -1 else 1
			local z = rng:NextNumber(startPoint.Z, endPoint.Z)
			local y = math.max(startPoint.Y, endPoint.Y) + rng:NextNumber(4, 18)
			addDecor(Vector3.new(cursor.X + side * rng:NextNumber(22, 34), y, z), theme.accent)
		end

		cursor = endPoint
	end

	local finishFolder = Instance.new("Folder")
	finishFolder.Name = string.format("%02d_Meta", TOTAL)
	finishFolder.Parent = obbyFolder
	currentFolder = finishFolder
	buildFinish(cursor, TOTAL)

	-- vacío mortal debajo de todo (en tramos de máx. 1000 studs)
	currentFolder = obbyFolder
	local zStart = CONFIG.Inicio.Z - 60
	local zEnd = cursor.Z + 100
	local z = zStart
	while z < zEnd do
		local len = math.min(1000, zEnd - z)
		makeKill(part({
			Name = "Vacio",
			Size = Vector3.new(500, 2, len),
			CFrame = CFrame.new(CONFIG.Inicio.X, CONFIG.Inicio.Y - CONFIG.ProfundidadVacio, z + len / 2),
			CanCollide = false,
			CastShadow = false,
			Color = Color3.fromRGB(110, 40, 200),
			Material = Enum.Material.ForceField,
		}))
		z += len
	end

	print(string.format("[SuperObby] Construido: %d etapas, %d studs de largo.", TOTAL, math.floor(cursor.Z - CONFIG.Inicio.Z)))
end

---------------------------------------------------------------------
-- GUARDADO
---------------------------------------------------------------------
local store = nil
if CONFIG.GuardarProgreso then
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(CONFIG.NombreDataStore)
	end)
	if ok then
		store = result
	else
		warn("[SuperObby] DataStore no disponible, no se guardará el progreso:", result)
	end
end

local function keyFor(player: Player): string
	return "Jugador_" .. player.UserId
end

local function loadPlayer(player: Player)
	if not store then
		return nil, false
	end
	for attempt = 1, 3 do
		local ok, result = pcall(function()
			return store:GetAsync(keyFor(player))
		end)
		if ok then
			return result, true
		end
		warn(string.format("[SuperObby] Error cargando a %s (intento %d): %s", player.Name, attempt, tostring(result)))
		if attempt < 3 then
			task.wait(attempt * 1.5)
		end
	end
	return nil, false
end

local function savePlayer(player: Player)
	local profile = profiles[player]
	-- si la carga falló no guardamos, para no borrar el progreso real
	if not store or not profile or not profile.canSave then
		return
	end
	local stage = getStage(player)
	local stats = player:FindFirstChild("leaderstats")
	local wins = stats and stats:FindFirstChild("Victorias")
	local data = { Stage = stage, Wins = if wins then wins.Value else 0, Best = profile.best }
	for attempt = 1, 3 do
		local ok, err = pcall(function()
			store:SetAsync(keyFor(player), data)
		end)
		if ok then
			return
		end
		warn(string.format("[SuperObby] Error guardando a %s (intento %d): %s", player.Name, attempt, tostring(err)))
		if attempt < 3 then
			task.wait(attempt)
		end
	end
end

---------------------------------------------------------------------
-- JUGADORES
---------------------------------------------------------------------
local function sendToStage(player: Player)
	local character = player.Character
	if not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
	if not root or player.Character ~= character then
		return
	end
	local stage = math.clamp(getStage(player), 1, TOTAL)
	local pad = checkpoints[stage] or checkpoints[1]
	character:PivotTo(pad.CFrame + Vector3.new(0, 4.5, 0))
end

local function onWin(player: Player)
	local profile = profiles[player]
	local stats = player:FindFirstChild("leaderstats")
	local wins = stats and stats:FindFirstChild("Victorias")
	if wins then
		wins.Value += 1
	end
	local message = "🏆 ¡COMPLETASTE EL OBBY!"
	if profile and profile.runStart then
		local elapsed = os.clock() - profile.runStart
		profile.runStart = nil
		message ..= "  Tiempo: " .. formatTime(elapsed)
		if not profile.best or elapsed < profile.best then
			profile.best = elapsed
			message ..= "  ¡NUEVO RÉCORD!"
		end
	end
	notify(player, message, GOLD, 6)
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			notify(other, "🏆 " .. player.DisplayName .. " completó el obby!", GOLD, 4)
		end
	end
end

reachStage = function(player: Player, stage: number)
	local current, value = getStage(player)
	if not value or stage <= current then
		return
	end
	local profile = profiles[player]
	if CONFIG.AntiSalto and stage > current + 1 then
		if profile and os.clock() - (profile.lastWarn or 0) > 3 then
			profile.lastWarn = os.clock()
			notify(player, string.format("⛔ ¡No te saltes etapas! Vuelve a la etapa %d", current + 1), RED)
		end
		return
	end
	value.Value = stage

	local pad = checkpoints[stage]
	local burst = pad:FindFirstChild("Explosion", true)
	if burst then
		burst:Emit(40)
	end
	local sound = pad:FindFirstChild("Ding")
	if sound then
		sound:Play()
	end

	if stage == TOTAL then
		onWin(player)
	else
		notify(player, string.format("✔ ¡Checkpoint! Etapa %d: %s", stage, stageNames[stage]), GREEN)
	end
end

resetPlayer = function(player: Player)
	local profile = profiles[player]
	local _, value = getStage(player)
	if not profile or not value or os.clock() - (profile.lastReset or 0) < 3 then
		return
	end
	profile.lastReset = os.clock()
	value.Value = 1
	profile.runStart = os.clock()
	sendToStage(player)
	notify(player, "🔄 ¡Otra vuelta! El cronómetro ya empezó.", WHITE)
end

local function onCharacter(player: Player, character: Model)
	-- esperamos a que el personaje esté en el mundo antes de moverlo
	local started = os.clock()
	while character.Parent ~= workspace and os.clock() - started < 5 do
		task.wait()
	end
	task.wait(0.1)
	if player.Character == character then
		sendToStage(player)
	end
end

local function onPlayerAdded(player: Player)
	local profile = { canSave = false }
	profiles[player] = profile

	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local stageValue = Instance.new("IntValue")
	stageValue.Name = "Etapa"
	stageValue.Value = 1
	stageValue.Parent = stats
	local winsValue = Instance.new("IntValue")
	winsValue.Name = "Victorias"
	winsValue.Parent = stats
	stats.Parent = player

	stageValue.Changed:Connect(function()
		updateHud(player)
	end)
	task.spawn(buildHud, player)

	player.CharacterAdded:Connect(function(character)
		onCharacter(player, character)
	end)
	if player.Character then
		task.spawn(onCharacter, player, player.Character)
	end

	local data, ok = loadPlayer(player)
	if not player.Parent then
		return
	end
	profile.canSave = ok
	if ok and type(data) == "table" then
		local saved = math.clamp(tonumber(data.Stage) or 1, 1, TOTAL)
		stageValue.Value = math.max(stageValue.Value, saved)
		winsValue.Value = tonumber(data.Wins) or 0
		profile.best = tonumber(data.Best)
	end

	if stageValue.Value == 1 then
		profile.runStart = os.clock()
	else
		sendToStage(player)
	end

	task.wait(2) -- deja que el HUD aparezca antes del mensaje
	if not player.Parent then
		return
	end
	if not ok and store then
		notify(player, "⚠ No se pudo cargar tu progreso: esta partida no se guardará.", GOLD, 5)
	elseif stageValue.Value > 1 then
		notify(player, string.format("💾 Progreso cargado: etapa %d", stageValue.Value), GREEN, 4)
	else
		local best = if profile.best then "  ·  Tu récord: " .. formatTime(profile.best) else ""
		notify(player, "¡Bienvenido al Super Obby! Llega a la meta." .. best, WHITE, 5)
	end
end

local function onPlayerRemoving(player: Player)
	savePlayer(player)
	profiles[player] = nil
	huds[player] = nil
end

---------------------------------------------------------------------
-- BUCLES
---------------------------------------------------------------------
local bulkParts, bulkCFrames = {}, {}

local function onHeartbeat()
	local t = os.clock()

	for _, mover in ipairs(movers) do
		mover.align.Position = mover.origin + mover.offset * math.sin(mover.w * t + mover.phase)
	end

	table.clear(bulkParts)
	table.clear(bulkCFrames)
	for _, pendulum in ipairs(pendulums) do
		local swing = pendulum.pivot * CFrame.Angles(0, 0, pendulum.amp * math.sin(pendulum.w * t + pendulum.phase))
		table.insert(bulkParts, pendulum.rope)
		table.insert(bulkCFrames, swing * CFrame.new(0, -pendulum.length / 2, 0))
		table.insert(bulkParts, pendulum.ball)
		table.insert(bulkCFrames, swing * CFrame.new(0, -pendulum.length, 0))
	end
	for _, d in ipairs(decor) do
		local a = t * d.spin
		table.insert(bulkParts, d.part)
		table.insert(bulkCFrames, CFrame.new(d.base + Vector3.new(0, math.sin(t + d.bob) * 1.5, 0)) * CFrame.Angles(a, a * 0.7, 0))
	end
	if #bulkParts > 0 then
		workspace:BulkMoveTo(bulkParts, bulkCFrames, Enum.BulkMoveMode.FireCFrameChanged)
	end

	for _, gate in ipairs(laserGates) do
		local on = ((t + gate.phase) % gate.period) < gate.onTime
		if on ~= gate.on then
			gate.on = on
			for _, beam in ipairs(gate.beams) do
				beam.Transparency = if on then 0 else 0.85
				beam.CanTouch = on
			end
		end
	end
end

-- Revisión por zona de los peligros que se mueven
local function hazardLoop()
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { obbyFolder }
	while true do
		task.wait(0.1)
		if #Players:GetPlayers() > 0 then
			for _, hazard in ipairs(hazards) do
				if hazard.part.Parent and (not hazard.active or hazard.active()) then
					for _, hit in ipairs(workspace:GetPartsInPart(hazard.part, params)) do
						killHit(hit)
					end
				end
			end
		end
	end
end

---------------------------------------------------------------------
-- INICIO
---------------------------------------------------------------------
if CONFIG.MejorarIluminacion then
	if not Lighting:FindFirstChild("ObbyBloom") then
		local bloom = Instance.new("BloomEffect")
		bloom.Name = "ObbyBloom"
		bloom.Intensity = 0.5
		bloom.Size = 20
		bloom.Threshold = 1.6
		bloom.Parent = Lighting
	end
	if not Lighting:FindFirstChild("ObbyColor") then
		local color = Instance.new("ColorCorrectionEffect")
		color.Name = "ObbyColor"
		color.Saturation = 0.15
		color.Contrast = 0.05
		color.Parent = Lighting
	end
end

Players.RespawnTime = CONFIG.TiempoReaparicion
buildObby()

RunService.Heartbeat:Connect(onHeartbeat)
task.spawn(hazardLoop)

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

-- guardado automático
task.spawn(function()
	while true do
		task.wait(CONFIG.AutoGuardado)
		for _, player in ipairs(Players:GetPlayers()) do
			task.spawn(savePlayer, player)
		end
	end
end)

-- guardar a todos si el servidor se cierra
game:BindToClose(function()
	local pending = 0
	for _, player in ipairs(Players:GetPlayers()) do
		pending += 1
		task.spawn(function()
			savePlayer(player)
			pending -= 1
		end)
	end
	local started = os.clock()
	while pending > 0 and os.clock() - started < 25 do
		task.wait(0.2)
	end
end)
