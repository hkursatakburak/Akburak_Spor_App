import logging
from motor.motor_asyncio import AsyncIOMotorClient
from config import settings

logger = logging.getLogger("uvicorn.error")

# Initialize asynchronous MongoDB client using settings config
client = AsyncIOMotorClient(settings.mongo_uri)

# Get database connection
# This automatically extracts database name from connection string URI or defaults to 'akb_app'
db = client.get_default_database()
if db is None or db.name in ("admin", "local"):
    db = client["akb_app"]

async def check_database_connection() -> bool:
    """Verifies MongoDB database connection by pinging the admin database."""
    try:
        # Ping the admin database to verify the connection is alive
        await client.admin.command("ping")
        logger.info("Successfully connected to the MongoDB database server!")
        return True
    except Exception as e:
        logger.error(f"Failed to connect to the MongoDB database server: {e}")
        return False

async def init_admin_user() -> None:
    """Safely initializes the default admin account with a hashed password in MongoDB."""
    try:
        from security import get_password_hash
        admin = await db["users"].find_one({"email": "admin@akburak.com"})
        if not admin:
            hashed_password = get_password_hash("admin123")
            admin_data = {
                "name": "Admin Eğitmen",
                "email": "admin@akburak.com",
                "hashed_password": hashed_password,
                "total_points": 2450,
                "rank": "Kara Kuşak",
                "longest_streak": 15,
                "badges": []
            }
            await db["users"].insert_one(admin_data)
            logger.info("Default admin user successfully initialized in database.")
        else:
            logger.info("Admin user already exists in database.")
    except Exception as e:
        logger.error(f"Error during admin user initialization: {e}")
