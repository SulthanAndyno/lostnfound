package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/gorilla/websocket"
	_ "github.com/glebarez/go-sqlite"
)

// Model structs matching Dart models
type Item struct {
	ID               string  `json:"id"`
	Status           string  `json:"status"`
	ItemName         string  `json:"itemName"`
	Location         string  `json:"location"`
	ImageURL         string  `json:"imageUrl"`
	Category         string  `json:"category"`
	Date             string  `json:"date"`
	Description      string  `json:"description"`
	ReporterName     string  `json:"reporterName"`
	ReporterAvatar   string  `json:"reporterAvatar"`
	ReporterRating   float64 `json:"reporterRating"`
	IsLostReport     bool    `json:"isLostReport"`
	ReportStatus     string  `json:"reportStatus"`
	IsCancelled      bool    `json:"isCancelled"`
	IsFoundCompleted bool    `json:"isFoundCompleted"`
	CampusName       string  `json:"campusName"`
}

type ChatMessage struct {
	ID         int64  `json:"id,omitempty"`
	ItemID     string `json:"itemId"`
	SenderName string `json:"senderName"`
	Message    string `json:"message"`
	Time       string `json:"time"`
	HasImage   bool   `json:"hasImage"`
	ImageURL   string `json:"imageUrl,omitempty"`
	IsMe       bool   `json:"isMe"` // Dynamic based on requesting client
}

// Global Variables
var (
	db       *sql.DB
	upgrader = websocket.Upgrader{
		CheckOrigin: func(r *http.Request) bool {
			return true // Allow all origins for Flutter development
		},
	}
	// Active connections mapped by itemId
	clients   = make(map[string]map[*websocket.Conn]bool)
	clientsMu sync.Mutex
)

func main() {
	var err error
	// Initialize SQLite Database
	db, err = sql.Open("sqlite", "lostnfound.db")
	if err != nil {
		log.Fatalf("Error opening database: %v", err)
	}
	defer db.Close()

	// Create tables
	createTables()

	// Seed initial data if database is empty
	seedInitialData()

	// Setup API Endpoints
	http.HandleFunc("/api/items", corsMiddleware(handleItems))
	http.HandleFunc("/api/items/", corsMiddleware(handleItemDetailsOrStatus))
	http.HandleFunc("/api/chats/", corsMiddleware(handleChatHistory))
	http.HandleFunc("/ws/chat", handleWebSocket)

	// Start server on port 8080 (binds to 0.0.0.0 so external devices can access)
	port := "8080"
	fmt.Printf("Server berjalan di http://0.0.0.0:%s\n", port)
	log.Fatal(http.ListenAndServe("0.0.0.0:"+port, nil))
}

func corsMiddleware(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next(w, r)
	}
}

func createTables() {
	itemTable := `
	CREATE TABLE IF NOT EXISTS items (
		id TEXT PRIMARY KEY,
		status TEXT,
		item_name TEXT,
		location TEXT,
		image_url TEXT,
		category TEXT,
		date TEXT,
		description TEXT,
		reporter_name TEXT,
		reporter_avatar TEXT,
		reporter_rating REAL,
		is_lost_report INTEGER,
		report_status TEXT,
		is_cancelled INTEGER,
		is_found_completed INTEGER,
		campus_name TEXT
	);`

	chatTable := `
	CREATE TABLE IF NOT EXISTS chat_messages (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		item_id TEXT,
		sender_name TEXT,
		message TEXT,
		time TEXT,
		has_image INTEGER,
		image_url TEXT
	);`

	if _, err := db.Exec(itemTable); err != nil {
		log.Fatalf("Error creating items table: %v", err)
	}
	if _, err := db.Exec(chatTable); err != nil {
		log.Fatalf("Error creating chat table: %v", err)
	}
}

func seedInitialData() {
	var count int
	err := db.QueryRow("SELECT COUNT(*) FROM items").Scan(&count)
	if err != nil {
		log.Fatalf("Error checking item count: %v", err)
	}
	if count > 0 {
		return // Already seeded
	}

	initialItems := []Item{
		{
			ID:               "1",
			Status:           "LOST REPORT",
			ItemName:         "DOMPET KULIT HITAM",
			Location:         "Gedung Perpustakaan Pusat, Lt. 2.",
			ImageURL:         "https://images.unsplash.com/photo-1627124118123-2854b3dbc19a?q=80&w=300",
			Category:         "Aksesoris & Personal",
			Date:             "12 Okt 2023",
			Description:      "Dompet kulit berwarna hitam merek 'Fossil'. Berisi kartu identitas (KTM), beberapa kartu ATM, dan uang tunai. Terakhir terlihat di meja area pelajar lantai 2 Perpustakaan Pusat.",
			ReporterName:     "Budi",
			ReporterAvatar:   "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=150",
			ReporterRating:   4.9,
			IsLostReport:     true,
			ReportStatus:     "DIPROSES",
			IsCancelled:      false,
			IsFoundCompleted: false,
			CampusName:       "Bandung",
		},
		{
			ID:               "2",
			Status:           "LOST REPORT",
			ItemName:         "HEADPHONE SONY",
			Location:         "Perpustakaan Kampus B",
			ImageURL:         "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=300",
			Category:         "Elektronik",
			Date:             "15 Okt 2023",
			Description:      "Headphone Sony WH-1000XM4 warna hitam. Terakhir diletakkan di meja perpustakaan Kampus B.",
			ReporterName:     "Siti",
			ReporterAvatar:   "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150",
			ReporterRating:   4.8,
			IsLostReport:     true,
			ReportStatus:     "DALAM KLAIM",
			IsCancelled:      false,
			IsFoundCompleted: false,
			CampusName:       "Bandung",
		},
		{
			ID:               "3",
			Status:           "LOST REPORT",
			ItemName:         "KUNCI KAMAR KOS",
			Location:         "Area Parkiran Kampus A",
			ImageURL:         "https://images.unsplash.com/photo-1582139329536-e7284fece509?q=80&w=300",
			Category:         "Lain-lain",
			Date:             "16 Okt 2023",
			Description:      "Gantungan kunci kamar kos dengan mainan boneka beruang warna coklat.",
			ReporterName:     "Rian",
			ReporterAvatar:   "https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=150",
			ReporterRating:   4.7,
			IsLostReport:     true,
			ReportStatus:     "BATAL",
			IsCancelled:      true,
			IsFoundCompleted: false,
			CampusName:       "Bandung",
		},
		{
			ID:               "4",
			Status:           "FOUND REPORT",
			ItemName:         "DOMPET KULIT HITAM",
			Location:         "Gedung Perpustakaan Pusat, Lt. 2.",
			ImageURL:         "https://images.unsplash.com/photo-1627124118123-2854b3dbc19a?q=80&w=300",
			Category:         "Aksesoris & Personal",
			Date:             "12 Okt 2023",
			Description:      "Dompet kulit berwarna hitam merek 'Fossil'. Ditemukan di meja area pelajar lantai 2 Perpustakaan Pusat.",
			ReporterName:     "Budi",
			ReporterAvatar:   "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=150",
			ReporterRating:   4.9,
			IsLostReport:     false,
			ReportStatus:     "DIPROSES",
			IsCancelled:      false,
			IsFoundCompleted: false,
			CampusName:       "Bandung",
		},
		{
			ID:               "5",
			Status:           "FOUND REPORT",
			ItemName:         "HEADPHONE SONY",
			Location:         "Telah diserahkan kepada pemilik\n12 September 2025.",
			ImageURL:         "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=300",
			Category:         "Elektronik",
			Date:             "15 Okt 2023",
			Description:      "Headphone Sony WH-1000XM4 warna hitam. Telah diserahkan kepada pemilik pada 12 September 2025.",
			ReporterName:     "Siti",
			ReporterAvatar:   "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150",
			ReporterRating:   4.8,
			IsLostReport:     false,
			ReportStatus:     "SELESAI",
			IsCancelled:      false,
			IsFoundCompleted: true,
			CampusName:       "Bandung",
		},
		{
			ID:               "6",
			Status:           "FOUND REPORT",
			ItemName:         "KUNCI KAMAR KOS",
			Location:         "Telah diserahkan kepada pemilik\n12 September 2025.",
			ImageURL:         "https://images.unsplash.com/photo-1582139329536-e7284fece509?q=80&w=300",
			Category:         "Lain-lain",
			Date:             "16 Okt 2023",
			Description:      "Kunci kamar kos dengan gantungan besi. Telah diserahkan kepada pemilik pada 12 September 2025.",
			ReporterName:     "Rian",
			ReporterAvatar:   "https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=150",
			ReporterRating:   4.7,
			IsLostReport:     false,
			ReportStatus:     "SELESAI",
			IsCancelled:      false,
			IsFoundCompleted: true,
			CampusName:       "Bandung",
		},
	}

	stmt, err := db.Prepare(`
		INSERT INTO items (
			id, status, item_name, location, image_url, category, date, description,
			reporter_name, reporter_avatar, reporter_rating, is_lost_report, report_status,
			is_cancelled, is_found_completed, campus_name
		) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	`)
	if err != nil {
		log.Fatalf("Error preparing insert statement: %v", err)
	}
	defer stmt.Close()

	for _, item := range initialItems {
		_, err := stmt.Exec(
			item.ID, item.Status, item.ItemName, item.Location, item.ImageURL, item.Category,
			item.Date, item.Description, item.ReporterName, item.ReporterAvatar, item.ReporterRating,
			b2i(item.IsLostReport), item.ReportStatus, b2i(item.IsCancelled), b2i(item.IsFoundCompleted),
			item.CampusName,
		)
		if err != nil {
			log.Fatalf("Error inserting item %s: %v", item.ID, err)
		}
	}
	log.Println("Database seeded successfully with initial data.")
}

func b2i(b bool) int {
	if b {
		return 1
	}
	return 0
}

func i2b(i int) bool {
	return i != 0
}

// Handlers
func handleItems(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
		campus := r.URL.Query().Get("campus")
		var rows *sql.Rows
		var err error

		if campus != "" {
			rows, err = db.Query("SELECT * FROM items WHERE LOWER(campus_name) = LOWER(?) ORDER BY id DESC", campus)
		} else {
			rows, err = db.Query("SELECT * FROM items ORDER BY id DESC")
		}

		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		defer rows.Close()

		items := []Item{}
		for rows.Next() {
			var item Item
			var isLostReport, isCancelled, isFoundCompleted int
			err := rows.Scan(
				&item.ID, &item.Status, &item.ItemName, &item.Location, &item.ImageURL, &item.Category,
				&item.Date, &item.Description, &item.ReporterName, &item.ReporterAvatar, &item.ReporterRating,
				&isLostReport, &item.ReportStatus, &isCancelled, &isFoundCompleted, &item.CampusName,
			)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			item.IsLostReport = i2b(isLostReport)
			item.IsCancelled = i2b(isCancelled)
			item.IsFoundCompleted = i2b(isFoundCompleted)
			items = append(items, item)
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(items)
		return
	}

	if r.Method == "POST" {
		var item Item
		if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		// Save item to database
		_, err := db.Exec(`
			INSERT INTO items (
				id, status, item_name, location, image_url, category, date, description,
				reporter_name, reporter_avatar, reporter_rating, is_lost_report, report_status,
				is_cancelled, is_found_completed, campus_name
			) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			item.ID, item.Status, item.ItemName, item.Location, item.ImageURL, item.Category,
			item.Date, item.Description, item.ReporterName, item.ReporterAvatar, item.ReporterRating,
			b2i(item.IsLostReport), item.ReportStatus, b2i(item.IsCancelled), b2i(item.IsFoundCompleted),
			item.CampusName,
		)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(item)
		return
	}

	http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
}

func handleItemDetailsOrStatus(w http.ResponseWriter, r *http.Request) {
	// Path format: /api/items/{id} or /api/items/{id}/status
	// Let's parse
	// Simple path parsing
	path := r.URL.Path[len("/api/items/"):]
	if path == "" {
		http.Error(w, "Not Found", http.StatusNotFound)
		return
	}

	// Check if this is a status update or detail fetch
	var id string
	isStatusUpdate := false

	// If path ends with /status
	const statusSuffix = "/status"
	if len(path) > len(statusSuffix) && path[len(path)-len(statusSuffix):] == statusSuffix {
		id = path[:len(path)-len(statusSuffix)]
		isStatusUpdate = true
	} else {
		id = path
	}

	if isStatusUpdate && r.Method == "POST" {
		// Update status
		type StatusPayload struct {
			Status string `json:"status"`
		}
		var payload StatusPayload
		if err := json.NewDecoder(r.Body).Decode(&payload); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		isCancelled := payload.Status == "BATAL"
		isFoundCompleted := payload.Status == "SELESAI"

		_, err := db.Exec("UPDATE items SET report_status = ?, is_cancelled = ?, is_found_completed = ? WHERE id = ?",
			payload.Status, b2i(isCancelled), b2i(isFoundCompleted), id)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, `{"success": true, "status": "%s"}`, payload.Status)
		return
	}

	if r.Method == "GET" {
		// Get single item
		var item Item
		var isLostReport, isCancelled, isFoundCompleted int
		err := db.QueryRow("SELECT * FROM items WHERE id = ?", id).Scan(
			&item.ID, &item.Status, &item.ItemName, &item.Location, &item.ImageURL, &item.Category,
			&item.Date, &item.Description, &item.ReporterName, &item.ReporterAvatar, &item.ReporterRating,
			&isLostReport, &item.ReportStatus, &isCancelled, &isFoundCompleted, &item.CampusName,
		)
		if err == sql.ErrNoRows {
			http.Error(w, "Item not found", http.StatusNotFound)
			return
		} else if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		item.IsLostReport = i2b(isLostReport)
		item.IsCancelled = i2b(isCancelled)
		item.IsFoundCompleted = i2b(isFoundCompleted)

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(item)
		return
	}

	http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
}

func handleChatHistory(w http.ResponseWriter, r *http.Request) {
	// Path format: /api/chats/{itemId}
	itemId := r.URL.Path[len("/api/chats/"):]
	if itemId == "" {
		http.Error(w, "Item ID is required", http.StatusBadRequest)
		return
	}

	if r.Method == "GET" {
		rows, err := db.Query("SELECT id, item_id, sender_name, message, time, has_image, image_url FROM chat_messages WHERE item_id = ? ORDER BY id ASC", itemId)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		defer rows.Close()

		messages := []ChatMessage{}
		// Check query parameter activeUser to dynamically determine 'isMe'
		activeUser := r.URL.Query().Get("activeUser")

		for rows.Next() {
			var msg ChatMessage
			var hasImage int
			var imgURL sql.NullString
			err := rows.Scan(&msg.ID, &msg.ItemID, &msg.SenderName, &msg.Message, &msg.Time, &hasImage, &imgURL)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			msg.HasImage = i2b(hasImage)
			if imgURL.Valid {
				msg.ImageURL = imgURL.String
			}
			msg.IsMe = msg.SenderName == activeUser
			messages = append(messages, msg)
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(messages)
		return
	}

	http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
}

// WebSocket connection handler
func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	itemId := r.URL.Query().Get("itemId")
	senderName := r.URL.Query().Get("senderName") // The active user connecting

	if itemId == "" || senderName == "" {
		http.Error(w, "itemId and senderName query parameters are required", http.StatusBadRequest)
		return
	}

	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("WebSocket Upgrade error: %v", err)
		return
	}
	defer conn.Close()

	// Register connection
	clientsMu.Lock()
	if clients[itemId] == nil {
		clients[itemId] = make(map[*websocket.Conn]bool)
	}
	clients[itemId][conn] = true
	clientsMu.Unlock()

	log.Printf("User '%s' terhubung ke WebSocket untuk item: %s", senderName, itemId)

	defer func() {
		clientsMu.Lock()
		if clients[itemId] != nil {
			delete(clients[itemId], conn)
			if len(clients[itemId]) == 0 {
				delete(clients, itemId)
			}
		}
		clientsMu.Unlock()
		log.Printf("User '%s' terputus dari WebSocket", senderName)
	}()

	// Read loop
	for {
		_, messageBytes, err := conn.ReadMessage()
		if err != nil {
			log.Printf("Read error: %v", err)
			break
		}

		// Parse incoming message
		type IncomingMessage struct {
			Message  string `json:"message"`
			HasImage bool   `json:"hasImage"`
			ImageURL string `json:"imageUrl"`
		}

		var incoming IncomingMessage
		if err := json.Unmarshal(messageBytes, &incoming); err != nil {
			log.Printf("Error unmarshaling socket message: %v", err)
			continue
		}

		now := time.Now()
		timeStr := fmt.Sprintf("%02d:%02d", now.Hour(), now.Minute())

		// Save message to SQLite database
		var imgURL sql.NullString
		if incoming.ImageURL != "" {
			imgURL.String = incoming.ImageURL
			imgURL.Valid = true
		}
		res, err := db.Exec("INSERT INTO chat_messages (item_id, sender_name, message, time, has_image, image_url) VALUES (?, ?, ?, ?, ?, ?)",
			itemId, senderName, incoming.Message, timeStr, b2i(incoming.HasImage), imgURL)
		if err != nil {
			log.Printf("Error saving chat message to DB: %v", err)
			continue
		}

		lastInsertID, _ := res.LastInsertId()

		// Broadcast message to all active clients for this itemId
		clientsMu.Lock()
		activeConns := clients[itemId]
		for clientConn := range activeConns {
			// For each recipient, compute whether the message "isMe"
			// (We let the client do this or we send a generic payload and let the client filter.
			// Let's send the full chat message payload with senderName, so the client knows who sent it.)
			payload := ChatMessage{
				ID:         lastInsertID,
				ItemID:     itemId,
				SenderName: senderName,
				Message:    incoming.Message,
				Time:       timeStr,
				HasImage:   incoming.HasImage,
				ImageURL:   incoming.ImageURL,
			}

			payloadBytes, err := json.Marshal(payload)
			if err != nil {
				log.Printf("Error marshaling payload: %v", err)
				continue
			}

			err = clientConn.WriteMessage(websocket.TextMessage, payloadBytes)
			if err != nil {
				log.Printf("Write error to connection: %v", err)
				clientConn.Close()
				delete(clients[itemId], clientConn)
			}
		}
		clientsMu.Unlock()
	}
}
