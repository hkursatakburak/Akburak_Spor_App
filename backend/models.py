from typing import Optional, List, Annotated, Union
from pydantic import BaseModel, Field, BeforeValidator, ConfigDict

# Helper type to handle MongoDB ObjectId mapping to string in Pydantic v2
PyObjectId = Annotated[str, BeforeValidator(str)]

class UserBadge(BaseModel):
    name: str
    description: str
    icon_url: Optional[str] = None
    date_earned: Optional[str] = None

class User(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    name: str
    email: str
    total_points: int = 0
    rank: str = "Başlangıç"
    longest_streak: int = 0
    badges: List[UserBadge] = []
    calories: int = 0
    workouts: int = 0
    minutes: int = 0

    model_config = ConfigDict(
        populate_by_name=True,
        json_schema_extra={
            "example": {
                "name": "Hamza Akburak",
                "email": "hamza@akburak.com",
                "total_points": 1500,
                "rank": "Kara Kuşak",
                "longest_streak": 12,
                "badges": [
                    {
                        "name": "İlk Yumruk",
                        "description": "İlk boks antrenmanını tamamladın",
                        "date_earned": "2026-07-17"
                    }
                ]
            }
        }
    )

class InstructorBadge(BaseModel):
    name: str
    level: str  # "Bronze" | "Silver" | "Gold"
    criteria: str
    instructor_id: str

class Instructor(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    name: str
    email: str
    badge_level: str = "Bronze"  # "Bronze" | "Silver" | "Gold"
    badges: List[InstructorBadge] = []

class ExerciseItem(BaseModel):
    name: str
    duration_seconds_or_reps: Union[int, str]
    video_url: Optional[str] = None

class WorkoutRoutine(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    title: str
    category: str
    duration_minutes: int
    difficulty: str
    cover_image_url: Optional[str] = None
    exercises: List[ExerciseItem] = []
    instructor_id: Optional[str] = None
    instructor_name: Optional[str] = "Hamza Akburak"
    instructor_badge_level: Optional[str] = "Bronze"  # "Bronze" | "Silver" | "Gold"

    model_config = ConfigDict(
        populate_by_name=True,
        json_schema_extra={
            "example": {
                "title": "Temel Gard Çalışması",
                "category": "Boks",
                "duration_minutes": 15,
                "difficulty": "Kolay",
                "cover_image_url": "https://images.unsplash.com/photo-1549719386-74dfcbf7dbed?q=80&w=800&auto=format&fit=crop",
                "instructor_id": "inst_01",
                "instructor_name": "Antrenör Hamza",
                "instructor_badge_level": "Gold",
                "exercises": [
                    {
                        "name": "Ayna Karşısında Gard Pozisyonu",
                        "duration_seconds_or_reps": "180",
                        "video_url": "https://example.com/video1"
                    }
                ]
            }
        }
    )

class Message(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    sender_id: str
    receiver_id: str
    content: str
    timestamp: str
    is_read: bool = False

    model_config = ConfigDict(
        populate_by_name=True,
        json_schema_extra={
            "example": {
                "sender_id": "user_123",
                "receiver_id": "inst_hamza",
                "content": "Hocam yarınki boks idmanı saat kaçta?",
                "timestamp": "2026-07-17T22:05:00Z",
                "is_read": False
            }
        }
    )


class WorkoutSessionRequest(BaseModel):
    duration_minutes: int
    kcal: int
    workout_type: str

