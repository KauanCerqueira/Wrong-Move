class_name ObservationBuilder
extends RefCounted

static func build(tournament: RefCounted, seat_id: int) -> Dictionary:
	return tournament.observation(seat_id).duplicate(true)
