def spawn_target(args)
  size = 64
  {
    x: rand(args.grid.w * 0.4) + args.grid.w * 0.6,
    y: rand(args.grid.h - size * 2) + size,
    w: size,
    h: size,
    path: 'sprites/target.png'
  }
end


def tick args
  args.state.player ||=  {
    x: 120,
    y: 280,
    w: 200,
    h: 80,
    speed: 12,
    path: 'sprites/misc/dragon-0.png',
  }
  
  args.state.fireballs ||= [] 
  args.state.targets ||= [
    spawn_target(args), spawn_target(args), spawn_target(args)
  
  ]

  args.state.score ||= 0
  args.state.timer ||= 30 * 60

  args.state.timer -= 1

  if args.state.timer < 0
    labels = []
    labels << {
      x: 40,
      y: args.grid.h - 40,
      text: "Game Over!",
      size_enum: 10,
    }
    labels << {
      x: 40,
      y: args.grid.h - 90,
      text: "Score: #{args.state.score}",
      size_enum: 4,
    }
    labels << {
      x: 40,
      y: args.grid.h - 132,
      text: "Fire to restart!",
      size_enum: 2,
    }

    if args.inputs.keyboard.key_down.z ||
        args.inputs.keyboard.key_down.j ||
        args.inputs.controller_one.key_down.a
      $gtk.reset
    end  

    return
  end
 if args.inputs.left
  args.state.player.x -= args.state.player.speed
 elsif args.inputs.right
  args.state.player.x += args.state.player.speed
 end

 if args.inputs.up
  args.state.player.y += args.state.player.speed
elsif args.inputs.down
  args.state.player.y -= args.state.player.speed
end

  if args.state.player.x + args.state.player.w > args.grid.w
    args.state.player.x = args.grid.w - args.state.player.w
  end

  if args.state.player.x < 0
    args.state.player.x = 0
  end

  if args.state.player.y + args.state.player.h > args.grid.h
    args.state.player.y = args.grid.h - args.state.player.y
  end

  if args.state.player.y < 0
    args.state.player.y = 0
  end

  if args.inputs.keyboard.key_down.z ||
      args.inputs.keyboard.key_down.j ||
      args.inputs.controller_one.key_down.a
    args.state.fireballs << {
      x: args.state.player.x + args.state.player.w - 12,
      y: args.state.player.y + 10,
      w: 32,
      h: 32,
      path: 'sprites/fireball.png',
    }
  end

  args.state.fireballs.each do |fireball|
    fireball.x += args.state.player.speed + 2

    if fireball.x > args.grid.w
      fireball.dead = true
      next
    end

    args.state.targets.each do |target|
      if args.geometry.intersect_rect?(target, fireball)
        target.dead = true
        fireball.dead = true
        args.state.score += 1
        args.state.targets << spawn_target(args)
      end
    end
  end

  args.state.targets.reject! { |t| t.dead }
  args.state.fireballs.reject! { |f| f.dead }

  args.outputs.labels << {
    x: 40,
    y: args.grid.h - 40,
    text: "Score: #{args.state.score}",
    size_enum: 4
  } 

  args.outputs.debug << {
    x: 40,
    y: args.grid.h - 80,
    text: "Fireballs: #{args.state.fireballs.length}",
  }.label!
  args.outputs.debug << {
    x: 40,
    y: args.grid.h - 100,
    text: "1st fireball x pos: #{args.state.fireballs.first&.x}",
  }.label!
  args.outputs.sprites << [args.state.player, args.state.fireballs, args.state.targets]

end

$gtk.reset