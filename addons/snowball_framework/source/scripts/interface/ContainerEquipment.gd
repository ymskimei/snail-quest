extends MarginContainer

onready var sprite = $ItemSprite
onready var label = $ItemSprite/ItemLabel

func item_display(item):
	if item is ResourceItem:
		sprite.texture = item.sprite
		if item.stackable:
			label.set_bbcode("[right]" + str(item.amount) + "[/right]")
		else:
			label.set_bbcode("")
	elif !item:
		sprite.texture = null
		label.set_bbcode("")
