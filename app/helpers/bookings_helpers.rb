def bookings_to_json(booking_class: Booking)
  booking_class.all.to_json
end
