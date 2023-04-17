def tick args
    $pong ||= PongGame.new
    $pong.args = args and
    $pong.tick
end