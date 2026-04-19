import mysql from 'mysql2/promise';

export default async function handler(req, res) {
  let db;
  try {
    db = await mysql.createConnection(process.env.DATABASE_URL);

    // --- FETCH BOOKINGS ---
    if (req.method === 'GET') {
      // Fetch Parking Bookings
      const [parking] = await db.execute(`
        SELECT b.booking_id as id, u.username, 'parking' as type, s.area_name as area, s.slot_code as slot, b.car_reg_no as regNo, b.start_time as startTime, b.end_time as endTime, b.total_cost as cost 
        FROM ParkingBookings b 
        JOIN Users u ON b.user_id = u.user_id 
        JOIN ParkingSlots s ON b.slot_id = s.slot_id
        WHERE b.booking_status = 'Confirmed'
      `);
      
      // Fetch EV Bookings
      const [ev] = await db.execute(`
        SELECT b.ev_booking_id as id, u.username, 'ev' as type, s.location_name as area, s.station_code as slot, b.car_reg_no as regNo, b.start_time as startTime, b.end_time as endTime, b.total_cost as cost 
        FROM EVBookings b 
        JOIN Users u ON b.user_id = u.user_id 
        JOIN EVStations s ON b.station_id = s.station_id
        WHERE b.booking_status = 'Confirmed'
      `);
      
      let allBookings = [...parking, ...ev];
      
      // Filter if a specific username was requested (for the dashboard)
      if (req.query.username) {
        allBookings = allBookings.filter(b => b.username === req.query.username);
      }
      
      return res.status(200).json(allBookings);
    } 
    
    // --- CREATE BOOKING ---
    else if (req.method === 'POST') {
      const { username, type, area, slot, regNo, startTime, endTime, cost } = req.body;
      
      // 1. Get User ID
      const [users] = await db.execute('SELECT user_id FROM Users WHERE username = ?', [username]);
      if (!users.length) return res.status(404).json({ error: 'User not found' });
      const user_id = users[0].user_id;

      const start = new Date(startTime);
      const end = new Date(endTime);

      // 2. Insert into appropriate table
      if (type === 'parking') {
        const [slots] = await db.execute('SELECT slot_id FROM ParkingSlots WHERE slot_code = ? AND area_name = ?', [slot, area]);
        const slot_id = slots[0].slot_id;
        
        const [result] = await db.execute(
          'INSERT INTO ParkingBookings (user_id, slot_id, car_reg_no, start_time, end_time, total_cost) VALUES (?, ?, ?, ?, ?, ?)',
          [user_id, slot_id, regNo, start, end, cost]
        );
        return res.status(200).json({ id: result.insertId });
        
      } else {
        const [stations] = await db.execute('SELECT station_id FROM EVStations WHERE station_code = ? AND location_name = ?', [slot, area]);
        const station_id = stations[0].station_id;
        
        const [result] = await db.execute(
          'INSERT INTO EVBookings (user_id, station_id, car_reg_no, start_time, end_time, total_cost) VALUES (?, ?, ?, ?, ?, ?)',
          [user_id, station_id, regNo, start, end, cost]
        );
        return res.status(200).json({ id: result.insertId });
      }
    }
    
    // --- CANCEL BOOKING ---
    else if (req.method === 'DELETE') {
      const { id, type } = req.query;
      
      if (type === 'parking') {
        await db.execute("UPDATE ParkingBookings SET booking_status = 'Cancelled' WHERE booking_id = ?", [id]);
      } else {
        await db.execute("UPDATE EVBookings SET booking_status = 'Cancelled' WHERE ev_booking_id = ?", [id]);
      }
      return res.status(200).json({ message: 'Cancelled successfully' });
    }
    
    // --- UNHANDLED METHODS ---
    else {
      return res.status(405).json({ error: 'Method not allowed' });
    }
    
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: error.message });
  } finally {
    if (db) await db.end();
  }
}