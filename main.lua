--como pode alguém fazer algo de forma tão ruim
lg = love.graphics
mt = love.math
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end

sprites = {lg.newImage('blob.png'),lg.newImage('food.png')}

bichos = {}
comidas = {}

cmGen = 100
cmQuan = 0
biPop = 20

dSense = 30
dSpeed = 3

time = 0
daySize = 300
dia = 0

mRate = 1
into = 20

wSize = 600
energy = 600

function createFood()
	table.insert(comidas,{x=mt.random(20,wSize-20),y=mt.random(20,wSize-20)})
	cmQuan = cmQuan + 1
end

function fillFood()	while cmQuan < cmGen do createFood() end end

function createBicho(x,y,sense,speed,size)
	table.insert(bichos,{x=x,y=y,sense=sense,speed=speed,size=size,food=0,energy=energy,mx=-1,my=-1,into=-1,procura=0,bico=-1})
end

function move(bicho,x,y)
	if (bichos[bicho]['x']==x and bichos[bicho]['y']==y) or bichos[bicho]['energy']<=0 then return end
	local angulo = math.angle(bichos[bicho]['x'],bichos[bicho]['y'],x,y)
	if math.abs(bichos[bicho]['x']-x)<bichos[bicho]['speed'] then bichos[bicho]['x']=x else
	bichos[bicho]['x']=bichos[bicho]['x']+(bichos[bicho]['speed']*dSpeed*math.cos(angulo)) end
	if math.abs(bichos[bicho]['y']-y)<bichos[bicho]['speed'] then bichos[bicho]['y']=y else
	bichos[bicho]['y']=bichos[bicho]['y']+(bichos[bicho]['speed']*dSpeed*math.sin(angulo)) end
	bichos[bicho]['energy']=bichos[bicho]['energy']-(math.pow(bichos[bicho]['size'],3)*math.pow(bichos[bicho]['speed'],2)+bichos[bicho]['sense'])
end

function love.load()
	fillFood()
	for i=1,50 do
		local pos = {mt.random(0,wSize),mt.random(0,1)*wSize}
		if mt.random(0,1)==0 then pos = {pos[2],pos[1]} end
		createBicho(pos[1],pos[2],1,1,1)
	end
	printGraphs()
end

function love.update()
	for b in ipairs(bichos) do
		if bichos[b]['food']==0 or (bichos[b]['food']==1 and time>=10*bichos[b]['speed'] and bichos[b]['energy']>energy/4) then
			local dist=999999
			for c in ipairs(comidas) do
				if math.sqrt((comidas[c]['x']-bichos[b]['x'])^2+(comidas[c]['y']-bichos[b]['y'])^2) < bichos[b]['sense']*dSense and math.dist(bichos[b]['x'],bichos[b]['y'],comidas[c]['x'],comidas[c]['y'])<dist then
					bichos[b]['mx'],bichos[b]['my'],bichos[b]['into'],dist,bichos[b]['procura'],bichos[b]['bico'] = comidas[c]['x'],comidas[c]['y'],into,math.dist(bichos[b]['x'],bichos[b]['y'],comidas[c]['x'],comidas[c]['y']),c,0
				end
			end
			for c in ipairs(bichos) do
				if c~=b and math.sqrt((bichos[c]['x']-bichos[b]['x'])^2+(bichos[c]['y']-bichos[b]['y'])^2) < bichos[b]['sense']*dSense and math.dist(bichos[b]['x'],bichos[b]['y'],bichos[c]['x'],bichos[c]['y'])<dist then
					if bichos[c]['size']<=(bichos[b]['size']/5)*4 then
						bichos[b]['mx'],bichos[b]['my'],bichos[b]['into'],dist,bichos[b]['procura'],bichos[b]['bico'] = bichos[c]['x'],bichos[c]['y'],into,math.dist(bichos[b]['x'],bichos[b]['y'],bichos[c]['x'],bichos[c]['y']),c,1
					elseif bichos[b]['procura']==c and bichos[b]['bico']==1 then
						local angulo = -math.angle(bichos[b]['x'],bichos[b]['y'],bichos[c]['x'],bichos[c]['y'])
						bichos[b]['mx'],bichos[b]['my'],bichos[b]['into'],dist,bichos[b]['procura'],bichos[b]['bico'] = bichos[b]['x']+(bichos[b]['speed']*dSpeed*math.cos(angulo)),bichos[b]['y']+(bichos[b]['speed']*dSpeed*math.sin(angulo)),into,0,0,-1
					end
				end
			end
			if bichos[b]['into']==-1 then bichos[b]['mx'],bichos[b]['my'],bichos[b]['into']=mt.random(0,wSize),mt.random(0,wSize),into end
			move(b,bichos[b]['mx'],bichos[b]['my'])
			bichos[b]['into']=bichos[b]['into']-1
			if bichos[b]['bico']==1 and bichos[bichos[b]['procura']] and math.dist(bichos[b]['x'],bichos[b]['y'],bichos[bichos[b]['procura']]['x'],bichos[bichos[b]['procura']]['y']) < 5 then
				bichos[b]['food']=bichos[b]['food']+1
				bichos[b]['mx'],bichos[b]['my'],bichos[b]['into']=-1,-1,-1
				table.remove(bichos,bichos[b]['procura'])
			elseif bichos[b]['bico']==0 and comidas[bichos[b]['procura']] and math.dist(bichos[b]['x'],bichos[b]['y'],comidas[bichos[b]['procura']]['x'],comidas[bichos[b]['procura']]['y']) < 5 then
				bichos[b]['food']=bichos[b]['food']+1
				table.remove(comidas,bichos[b]['procura'])
				cmQuan=cmQuan-1
				bichos[b]['mx'],bichos[b]['my'],bichos[b]['into'],bichos[b]['procura'],bichos[b]['bico']=-1,-1,-1,0,-1
			end 
		elseif not (bichos[b]['x']==0 or bichos[b]['y']==0 or bichos[b]['x']==wSize or bichos[b]['y']==wSize) then
			--provavelmente umas das formas mais idiotas de se fazer isso
			local dist,bordn=999999,0
			local dx,dy=0,0

			local nd=math.dist(bichos[b]['x'],bichos[b]['y'],bichos[b]['x'],0)
			if nd<dist then dx,dy,dist=bichos[b]['x'],0,nd end

			local nd=math.dist(bichos[b]['x'],bichos[b]['y'],0,bichos[b]['y'])
			if nd<dist then dx,dy,dist=0,bichos[b]['y'],nd end

			local nd=math.dist(bichos[b]['x'],bichos[b]['y'],bichos[b]['x'],wSize)
			if nd<dist then dx,dy,dist=bichos[b]['x'],wSize,nd end

			local nd=math.dist(bichos[b]['x'],bichos[b]['y'],wSize,bichos[b]['y'])
			if nd<dist then dx,dy,dist=wSize,bichos[b]['y'],nd end

			move(b,dx,dy)
			if dist<3 then bichos[b]['x'],bichos[b]['y'],bichos[b]['energy']=dx,dy,0 end
		end
	end
	time=time+1
	if time==daySize then
		printGraphs()
		time=0
		for b = #bichos, 1, -1 do
			if bichos[b]['food']==0 or not (bichos[b]['x']==0 or bichos[b]['y']==0 or bichos[b]['x']==wSize or bichos[b]['y']==wSize) then table.remove(bichos,b) end
		end
		for b in ipairs(bichos) do
			if bichos[b]['food']==2 then
				createBicho(bichos[b]['x']+mt.random(-4,4),bichos[b]['y']+mt.random(-4,4),
					bichos[b]['sense']+(mt.random(-mRate,mRate)/10),
					bichos[b]['speed']+(mt.random(-mRate,mRate)/10),
					bichos[b]['size'] +(mt.random(-mRate,mRate)/10))
			end
			bichos[b]['food']=0
			bichos[b]['energy']=energy
		end
		cmQuan=0
		comidas={}
		fillFood()
		dia=dia+1
		printGraphs()
	end
end

function love.draw()
	love.graphics.setColor(0.1, 0.1, 0.15)
	lg.rectangle('fill',0,0,wSize,wSize)
	love.graphics.setColor(1, 1, 1)
	for i in ipairs(comidas) do
		lg.draw(sprites[2],comidas[i]['x']-4,comidas[i]['y']-4)
	end
	for i in ipairs(bichos) do
		lg.draw(sprites[1],bichos[i]['x']-(16*bichos[i]['size']),bichos[i]['y']-(16*bichos[i]['size']),0,bichos[i]['size'],bichos[i]['size'])
		lg.print(bichos[i]['food']..'\n'..math.floor(bichos[i]['energy']),bichos[i]['x']-(16*bichos[i]['size']),bichos[i]['y']-(16*bichos[i]['size']))
	end
	lg.print('Time: '..time..'\nDia: '..dia,0,0)
end

function graph(var)
	local texto=''
	local lista={}
	for i = 1,27 do
		lista[i]=0
	end
	for b in ipairs(bichos) do
		if bichos[b][var]*10<=#lista then lista[math.floor(bichos[b][var]*10)]=lista[math.floor(bichos[b][var]*10)]+1 end
	end
	for i in ipairs(lista) do
		if string.len(lista[i]..'')==1 then lista[i]='0'..lista[i] end
		texto=texto..'|'..lista[i]
	end
	return texto..'|'
end

function printGraphs()
	local texto=''
	if time==0 then texto='Inicio do dia '..dia..','
	else texto='Fim do dia '..dia..',   ' end
	texto=texto..' Populacao: '..#bichos
	print(texto)
	print('Speed: '..graph('speed'))
	print('Size : '..graph('size'))
	print('Sense: '..graph('sense'))
	print('')
end

function love.keyreleased(key)
	if key == "space" then
		if love.window.getVSync() == 0 then
			love.window.setVSync(1)
		else
			love.window.setVSync(0)
		end
	end
end