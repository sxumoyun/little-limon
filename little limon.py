import mysql.connector

# MySQL bazasiga ulanish
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="YOUR_PASSWORD", # O'z parolingizni yozing
    database="LittleLemonDB"
)

cursor = db.cursor()

# Misol 1: GetMaxQuantity protsedurasini chaqirish
cursor.callproc("GetMaxQuantity")
for result in cursor.stored_results():
    print("Max Quantity:", result.fetchall())

# Misol 2: AddBooking protsedurasini chaqirish
cursor.callproc("AddBooking", (101, 1, '2026-06-15', 3))
db.commit()
print("Yangi bron muvaffaqiyatli qo'shildi!")

# Ulanishni yopish
cursor.close()
db.close()