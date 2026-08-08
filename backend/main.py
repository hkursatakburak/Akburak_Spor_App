from contextlib import asynccontextmanager
from datetime import datetime, timezone
from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from typing import List
from models import WorkoutRoutine, ExerciseItem, User, Message, WorkoutSessionRequest
from database import db, check_database_connection, init_admin_user
from security import verify_password, get_password_hash, create_access_token
from jose import jwt

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Verify DB connection on startup
    db_connected = await check_database_connection()
    if db_connected:
        await init_admin_user()
    yield

app = FastAPI(
    title="Akburak Spor Kulübü API",
    description="Asynchronous backend API for Akburak Spor Kulübü app using FastAPI and MongoDB",
    version="1.0.0",
    lifespan=lifespan
)

# Enable CORS for Flutter app local development communication
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Realistically structured mock data covering major app categories
MOCK_WORKOUTS = {
    "boks": [
        WorkoutRoutine(
            title="Temel Gard Çalışması",
            category="Boks",
            duration_minutes=15,
            difficulty="Kolay",
            cover_image_url="https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?q=80&w=800&auto=format&fit=crop",
            instructor_id="inst_hamza",
            instructor_name="Hamza Kürşat Akburak",
            instructor_badge_level="Gold",
            exercises=[
                ExerciseItem(name="Ayna Karşısında Gard Pozisyonu", duration_seconds_or_reps="180", video_url="https://example.com/video1"),
                ExerciseItem(name="Sol Direk Çıkışları", duration_seconds_or_reps="20", video_url=None),
                ExerciseItem(name="Gölge Boksu", duration_seconds_or_reps="300", video_url=None),
            ]
        ),
        WorkoutRoutine(
            title="Kum Torbası Kondisyon",
            category="Boks",
            duration_minutes=20,
            difficulty="Orta",
            cover_image_url="https://images.unsplash.com/photo-1599058917212-d750089bc07e?q=80&w=800&auto=format&fit=crop",
            instructor_id="inst_ali",
            instructor_name="Ali Demir",
            instructor_badge_level="Silver",
            exercises=[
                ExerciseItem(name="Kum Torbasında Direk Serileri", duration_seconds_or_reps="180", video_url=None),
                ExerciseItem(name="Kum Torbasında Kombinasyon (Direk-Kroşe)", duration_seconds_or_reps="180", video_url=None),
                ExerciseItem(name="İp Atlama", duration_seconds_or_reps="300", video_url=None),
            ]
        )
    ],
    "wushu sanda": [
        WorkoutRoutine(
            title="Temel Tekme Kombinasyonları",
            category="Wushu Sanda",
            duration_minutes=25,
            difficulty="Orta",
            cover_image_url="https://images.unsplash.com/photo-1555597673-b21d5c935865?q=80&w=800&auto=format&fit=crop",
            instructor_id="inst_hamza",
            instructor_name="Hamza Kürşat Akburak",
            instructor_badge_level="Gold",
            exercises=[
                ExerciseItem(name="Gölge Boksu + Düşük Tekme", duration_seconds_or_reps="240", video_url=None),
                ExerciseItem(name="Orta Seviye Tekme (Tui)", duration_seconds_or_reps="15", video_url=None),
            ]
        ),
        WorkoutRoutine(
            title="Sanda Dayanıklılık",
            category="Wushu Sanda",
            duration_minutes=30,
            difficulty="Zor",
            cover_image_url="https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=800&auto=format&fit=crop",
            instructor_id="inst_can",
            instructor_name="Can Yılmaz",
            instructor_badge_level="Bronze",
            exercises=[
                ExerciseItem(name="Kum Torbasında Sürekli Tekme-Yumruk", duration_seconds_or_reps="300", video_url=None),
                ExerciseItem(name="Hızlı Takla & Çıkış Antrenmanı", duration_seconds_or_reps="10", video_url=None),
            ]
        )
    ],
    "kardiyo": [
        WorkoutRoutine(
            title="Tüm Vücut Yağ Yakımı",
            category="Kardiyo",
            duration_minutes=15,
            difficulty="Orta",
            cover_image_url="https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=800&auto=format&fit=crop",
            instructor_id="inst_ayse",
            instructor_name="Ayşe Kaya",
            instructor_badge_level="Gold",
            exercises=[
                ExerciseItem(name="Jumping Jacks", duration_seconds_or_reps="45", video_url=None),
                ExerciseItem(name="Burpees", duration_seconds_or_reps="15", video_url=None),
                ExerciseItem(name="Plank Jacks", duration_seconds_or_reps="30", video_url=None),
            ]
        )
    ],
    "evde": [
        WorkoutRoutine(
            title="Ekipmansız Vücut Ağırlığı",
            category="Evde",
            duration_minutes=20,
            difficulty="Kolay",
            cover_image_url="https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=800&auto=format&fit=crop",
            instructor_id="inst_ali",
            instructor_name="Ali Demir",
            instructor_badge_level="Silver",
            exercises=[
                ExerciseItem(name="Şınav (Push Up)", duration_seconds_or_reps="15", video_url=None),
                ExerciseItem(name="Squat", duration_seconds_or_reps="20", video_url=None),
                ExerciseItem(name="Plank", duration_seconds_or_reps="60", video_url=None),
            ]
        ),
        WorkoutRoutine(
            title="Ev Tipi Kardiyo",
            category="Evde",
            duration_minutes=15,
            difficulty="Kolay",
            cover_image_url="https://images.unsplash.com/photo-1434596994283-7a4cc37c3a1d?q=80&w=800&auto=format&fit=crop",
            instructor_id="inst_can",
            instructor_name="Can Yılmaz",
            instructor_badge_level="Bronze",
            exercises=[
                ExerciseItem(name="High Knees", duration_seconds_or_reps="30", video_url=None),
                ExerciseItem(name="Mountain Climbers", duration_seconds_or_reps="30", video_url=None),
            ]
        )
    ],
    "kulüpte": [
        WorkoutRoutine(
            title="Ağır Sağlam Güç",
            category="Kulüpte",
            duration_minutes=45,
            difficulty="Zor",
            cover_image_url="https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=800&auto=format&fit=crop",
            instructor_id="inst_hamza",
            instructor_name="Hamza Kürşat Akburak",
            instructor_badge_level="Gold",
            exercises=[
                ExerciseItem(name="Bench Press", duration_seconds_or_reps="5x5", video_url=None),
                ExerciseItem(name="Deadlift", duration_seconds_or_reps="5x5", video_url=None),
                ExerciseItem(name="Squat", duration_seconds_or_reps="5x5", video_url=None),
            ]
        ),
        WorkoutRoutine(
            title="İstasyon Çalışması",
            category="Kulüpte",
            duration_minutes=30,
            difficulty="Orta",
            cover_image_url="https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=800&auto=format&fit=crop",
            instructor_id="inst_ayse",
            instructor_name="Ayşe Kaya",
            instructor_badge_level="Gold",
            exercises=[
                ExerciseItem(name="Kettlebell Swing", duration_seconds_or_reps="45", video_url=None),
                ExerciseItem(name="Battling Ropes", duration_seconds_or_reps="30", video_url=None),
            ]
        )
    ],
    "dışarıda": [
        WorkoutRoutine(
            title="Parkta Kondisyon",
            category="Dışarıda",
            duration_minutes=25,
            difficulty="Orta",
            cover_image_url="https://images.unsplash.com/photo-1502224562085-639556652f33?q=80&w=800&auto=format&fit=crop",
            instructor_id="inst_can",
            instructor_name="Can Yılmaz",
            instructor_badge_level="Bronze",
            exercises=[
                ExerciseItem(name="Koşu (Hafif Tempo)", duration_seconds_or_reps="600", video_url=None),
                ExerciseItem(name="Barfiks (Pull Up)", duration_seconds_or_reps="10", video_url=None),
                ExerciseItem(name="Dips", duration_seconds_or_reps="15", video_url=None),
            ]
        )
    ]
}


security = HTTPBearer()

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> User:
    """FastAPI dependency to extract JWT token from header and load the current user."""
    token = credentials.credentials
    try:
        from security import JWT_SECRET, JWT_ALGORITHM
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        email = payload.get("sub")
        if not email:
            raise HTTPException(status_code=401, detail="Geçersiz jeton içeriği.")
        user_data = await db["users"].find_one({"email": email})
        if not user_data:
            raise HTTPException(status_code=401, detail="Kullanıcı bulunamadı.")
        return User(**user_data)
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Kimlik doğrulama başarısız: {e}")

@app.get("/api/user/profile", response_model=User)
async def get_user_profile(current_user: User = Depends(get_current_user)):
    """Fetch the profile details of the currently authenticated user."""
    return current_user

@app.post("/api/user/workout-session")
async def submit_workout_session(req: WorkoutSessionRequest, current_user: User = Depends(get_current_user)):
    """Record completed workout sessions, increment points, workouts, calories, and duration."""
    points_gained = 10
    
    # Check if they earn the "İlk Yumruk" badge
    badges = current_user.badges
    has_first_badge = any(b.name == "İlk Yumruk" for b in badges)
    
    update_query = {
        "$inc": {
            "total_points": points_gained,
            "calories": req.kcal,
            "workouts": 1,
            "minutes": req.duration_minutes
        }
    }
    
    if not has_first_badge:
        # Earn the first badge!
        new_badge = {
            "name": "İlk Yumruk",
            "description": "İlk antrenmanını tamamladın!",
            "date_earned": datetime.now(timezone.utc).strftime("%Y-%m-%d")
        }
        update_query["$push"] = {"badges": new_badge}
        # Award bonus points for the badge
        update_query["$inc"]["total_points"] += 20
        print("Awarded first workout badge: İlk Yumruk")
        
    await db["users"].update_one(
        {"email": current_user.email},
        update_query
    )
    return {
        "status": "success",
        "message": "Antrenman başarıyla kaydedildi.",
        "badge_earned": not has_first_badge
    }


@app.get("/")
async def root():
    return {
        "status": "success",
        "message": "Akburak Spor Kulübü API is running! 🥊"
    }

@app.get("/api/workouts/{category}", response_model=List[WorkoutRoutine])
async def get_workouts_by_category(category: str):
    # Normalize category string for comparison (lowercase)
    cat_key = category.lower().strip()
    
    # Check direct match
    if cat_key in MOCK_WORKOUTS:
        return MOCK_WORKOUTS[cat_key]
        
    # Attempt substring or matching logic
    for key, routines in MOCK_WORKOUTS.items():
        if key in cat_key or cat_key in key:
            return routines
            
    # Default to returning an empty list to prevent frontend crash on missing mock items
    return []

from pydantic import BaseModel

class AuthRequest(BaseModel):
    email: str
    password: str

@app.post("/api/auth/login")
async def login(req: AuthRequest):
    # Query user from MongoDB
    user = await db["users"].find_one({"email": req.email})
    if not user:
        raise HTTPException(status_code=401, detail="E-posta adresi veya şifre hatalı.")
    
    # Verify the password using bcrypt
    hashed_password = user.get("hashed_password")
    if not hashed_password or not verify_password(req.password, hashed_password):
        raise HTTPException(status_code=401, detail="E-posta adresi veya şifre hatalı.")
    
    role = "admin" if req.email == "admin@akburak.com" else "user"
    token = create_access_token({"sub": req.email, "role": role})
    
    return {
        "status": "success",
        "token": token,
        "user": {
            "name": user.get("name", "Sporcu"),
            "email": req.email,
            "role": role
        }
    }

@app.post("/api/auth/register")
async def register(req: AuthRequest):
    # Check if user already exists
    existing_user = await db["users"].find_one({"email": req.email})
    if existing_user:
        raise HTTPException(status_code=400, detail="Bu e-posta adresi zaten kayıtlı.")
    
    # Hash password and store user
    hashed_password = get_password_hash(req.password)
    user_data = {
        "name": "Yeni Sporcu",
        "email": req.email,
        "hashed_password": hashed_password,
        "total_points": 0,
        "rank": "Başlangıç",
        "longest_streak": 0,
        "badges": []
    }
    await db["users"].insert_one(user_data)
    
    token = create_access_token({"sub": req.email, "role": "user"})
    
    return {
        "status": "success",
        "token": token,
        "user": {
            "name": "Yeni Sporcu",
            "email": req.email,
            "role": "user"
        }
    }

@app.get("/api/leaderboard", response_model=List[User])
async def get_leaderboard():
    try:
        users_cursor = db["users"].find().sort("total_points", -1).limit(10)
        users = await users_cursor.to_list(length=10)
        if not users:
            raise HTTPException(status_code=404, detail="No users found")
        return users
    except Exception:
        # Fallback to realistic pre-populated mock leaderboard
        return [
            User(name="Hamza Kürşat Akburak", email="hamza@akburak.com", total_points=2450, rank="Kara Kuşak", longest_streak=15, badges=[]),
            User(name="Ali Demir", email="ali@akburak.com", total_points=2100, rank="Kahverengi Kuşak", longest_streak=12, badges=[]),
            User(name="Ayşe Kaya", email="ayse@akburak.com", total_points=1950, rank="Mavi Kuşak", longest_streak=9, badges=[]),
            User(name="Can Yılmaz", email="can@akburak.com", total_points=1700, rank="Mavi Kuşak", longest_streak=4, badges=[]),
            User(name="Deniz Yıldız", email="deniz@akburak.com", total_points=1500, rank="Yeşil Kuşak", longest_streak=8, badges=[]),
            User(name="Fatma Çelik", email="fatma@akburak.com", total_points=1350, rank="Yeşil Kuşak", longest_streak=2, badges=[]),
            User(name="Burak Şahin", email="burak@akburak.com", total_points=1100, rank="Sarı Kuşak", longest_streak=6, badges=[]),
            User(name="Gözde Öztürk", email="gozde@akburak.com", total_points=950, rank="Sarı Kuşak", longest_streak=3, badges=[]),
            User(name="Mehmet Yılmaz", email="mehmet@akburak.com", total_points=800, rank="Beyaz Kuşak", longest_streak=1, badges=[]),
            User(name="Zeynep Kaya", email="zeynep@akburak.com", total_points=650, rank="Beyaz Kuşak", longest_streak=7, badges=[]),
        ]

CHAT_MESSAGES = [
    Message(sender_id="inst_hamza", receiver_id="user_123", content="Merhaba sporcu, antrenmanlar nasıl gidiyor? 🥊", timestamp="2026-07-17T22:00:00Z", is_read=True),
    Message(sender_id="user_123", receiver_id="inst_hamza", content="Harika gidiyor hocam! Boks torbası serilerini yapıyorum.", timestamp="2026-07-17T22:05:00Z", is_read=True),
    Message(sender_id="inst_hamza", receiver_id="user_123", content="Süper, gardını yüksek tutmayı unutma! Yarın kontrol edeceğim.", timestamp="2026-07-17T22:06:00Z", is_read=True),
]

@app.post("/api/messages/send")
async def send_message(msg: Message):
    CHAT_MESSAGES.append(msg)
    print(f"\n🔔 [MOCK PUSH NOTIFICATION] - ALICI: {msg.receiver_id} - GÖNDEREN: {msg.sender_id} - İÇERİK: '{msg.content}'\n")
    return {"status": "success", "message": msg}

@app.get("/api/messages/{trainer_id}")
async def get_messages(trainer_id: str, user_id: str = "user_123"):
    history = [
        msg for msg in CHAT_MESSAGES
        if (msg.sender_id == trainer_id and msg.receiver_id == user_id) or
           (msg.sender_id == user_id and msg.receiver_id == trainer_id)
    ]
    return history
