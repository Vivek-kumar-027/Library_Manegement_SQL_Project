import random, datetime as dt, os
random.seed(42)
out=[]
cats=["Fiction","Science","History","Technology","Mathematics","Biography","Fantasy","Self-Help"]
out.append("INSERT INTO categories(name) VALUES "+",".join(f"('{c}')" for c in cats)+";")
authors=[("Chinua Achebe","Nigeria"),("Yuval Noah Harari","Israel"),("Carl Sagan","USA"),("R.K. Narayan","India"),
("Jane Austen","UK"),("Isaac Asimov","USA"),("Ada Palmer","USA"),("Arundhati Roy","India"),("Donald Knuth","USA"),
("Malala Yousafzai","Pakistan"),("Haruki Murakami","Japan"),("Brandon Sanderson","USA"),("James Clear","USA"),
("Ruskin Bond","India"),("Stephen Hawking","UK")]
out.append("INSERT INTO authors(full_name,country) VALUES "+",".join(f"('{a}','{c}')" for a,c in authors)+";")
books=[("Things Fall Apart",1,1958,3,[1]),("Sapiens",3,2011,4,[2]),("Cosmos",2,1980,3,[3]),("Malgudi Days",1,1943,3,[4]),
("Pride and Prejudice",1,1813,3,[5]),("Foundation",1,1951,2,[6]),("Too Like the Lightning",7,2016,2,[7]),
("The God of Small Things",1,1997,3,[8]),("The Art of Computer Programming",4,1968,2,[9]),("I Am Malala",6,2013,3,[10]),
("Norwegian Wood",1,1987,2,[11]),("Mistborn",7,2006,3,[12]),("Atomic Habits",8,2018,5,[13]),("The Blue Umbrella",1,1980,2,[14]),
("A Brief History of Time",2,1988,4,[15]),("Homo Deus",3,2015,3,[2]),("Contact",1,1985,2,[3]),("I, Robot",1,1950,2,[6]),
("The Way of Kings",7,2010,3,[12]),("Kafka on the Shore",1,2002,2,[11]),("Pale Blue Dot",2,1994,2,[3]),
("Rusty Goes to London",1,1989,2,[14]),("The Universe in a Nutshell",2,2001,2,[15]),("Elantris",7,2005,2,[12]),
("Discrete Mathematics Primer",5,2015,4,[9]),("The Ministry of Utmost Happiness",1,2017,2,[8]),
("21 Lessons for the 21st Century",3,2018,3,[2]),("Algorithms Unlocked",4,2013,3,[9]),("Calculus Made Easy",5,1910,3,[6]),
("Swami and Friends",1,1935,2,[4])]
q=lambda s:s.replace("'","''")
out.append("INSERT INTO books(title,category_id,published_year,copies_total) VALUES "+",".join(f"('{q(t)}',{c},{y},{n})" for t,c,y,n,_ in books)+";")
ba=[(i+1,a) for i,b in enumerate(books) for a in b[4]]
out.append("INSERT INTO book_authors VALUES "+",".join(f"({b},{a})" for b,a in ba)+";")
first=["Aarav","Diya","Rohan","Meera","Kabir","Ananya","Vihaan","Isha","Arjun","Saanvi","Neel","Tara","Rahul","Priya","Dev","Nisha","Karan","Zoya","Ishaan","Riya","Manav","Pooja","Sahil","Anika","Yash"]
last=["Sharma","Patel","Iyer","Khan","Reddy","Das","Singh","Nair","Gupta","Mehta"]
mem=[]
for i,f in enumerate(first):
    t=random.choices(["student","teacher","public"],[6,1,3])[0]
    j=dt.date(2025,1,1)+dt.timedelta(days=random.randint(0,500))
    mem.append((f"{f} {last[i%10]}",f"{f.lower()}{i+1}@example.com",t,j.isoformat()))
out.append("INSERT INTO members(full_name,email,member_type,joined_on) VALUES "+",".join(f"('{a}','{b}','{c}','{d}')" for a,b,c,d in mem)+";")
pop=[3,3,2,2,1,1,1,1,1,2,1,2,5,1,3,2,1,1,2,1,1,1,1,1,2,1,2,2,1,1]
loans=[];fines=[]
today=dt.date(2026,10,17)
for lid in range(1,221):
    b=random.choices(range(1,31),pop)[0]; m=random.randint(1,25)
    bo=dt.date(2026,1,1)+dt.timedelta(days=random.randint(0,290))
    due=bo+dt.timedelta(days=14)
    if bo>today-dt.timedelta(days=20) and random.random()<0.6:
        ret="NULL"
    else:
        if random.random()<0.7:
            r=due-dt.timedelta(days=random.randint(0,10))
        else:
            r=due+dt.timedelta(days=random.randint(1,25))
        r=max(r,bo)
        ret=f"'{r.isoformat()}'"
        if r>due: fines.append((lid,round((r-due).days*2.0,2),random.choice([0,1])))
    loans.append(f"({b},{m},'{bo}','{due}',{ret})")
out.append("INSERT INTO loans(book_id,member_id,borrowed_on,due_on,returned_on) VALUES "+",".join(loans)+";")
out.append("INSERT INTO fines(loan_id,amount,paid) VALUES "+",".join(f"({a},{b},{c})" for a,b,c in fines)+";")
here=os.path.dirname(os.path.abspath(__file__))
open(os.path.join(here,"02_seed_data.sql"),"w").write("\n".join(out)+"\n")
