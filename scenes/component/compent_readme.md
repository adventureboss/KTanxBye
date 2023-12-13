# components

The types of scenes that belong in here are bits that control
certain features in the game.

Examples would be:
	- death_component
	- health_component
	- hitbox_component
	- hurtbox_component
	- item_drop_component
	
These thing are imported into other objects in the game using composition.

A player for instance needs an instance of death, health, hurt, and hit so it can take all the actions it needs.

A new item that falls on the screenw ould need item_drop so it gets instructison on what it's supposed to be.
