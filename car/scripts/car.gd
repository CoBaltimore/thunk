extends CharacterBody2D

var wheelBase = 70
var steeringAngle = 20

var enginePower = 300
var acceleration = Vector2.ZERO

var steerDirection

var friction = -0.9
var drag = -0.0015

var braking = -450
var maxSpeedReverse = 250

var slipSpeed = 400
var tractionFast = 0.1
var tractionSlow = 0.7

func _physics_process(delta):
	acceleration = Vector2.ZERO
	getInput()
	applyFriction(delta)
	calculateSteering(delta)
	velocity += acceleration * delta
	move_and_slide()

func getInput():
	var turn = Input.get_axis("steer_left", "steer_right")
	steerDirection = turn * deg_to_rad(steeringAngle)
	
	if Input.is_action_pressed("accelerate"):
		velocity = transform.x * enginePower
	
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking

func calculateSteering(delta):
	var rearWheel = position - transform.x * wheelBase / 2.0
	var frontWheel = position + transform.x * wheelBase / 2.0
	rearWheel += velocity * delta
	frontWheel += velocity.rotated(steerDirection) * delta
	var newHeading = rearWheel.direction_to(frontWheel)
	var d = newHeading.dot(velocity.normalized())
	if d > 0:
		velocity = newHeading * velocity.length()
	if d < 0:
		velocity = -newHeading * min(velocity.length(), maxSpeedReverse)
	rotation = newHeading.angle()

func applyFriction(delta):
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var frictionForce = velocity * friction
	var dragForce = velocity * velocity.length() * drag
	if velocity.length() < 100:
		frictionForce *= 3
	acceleration += dragForce + frictionForce
