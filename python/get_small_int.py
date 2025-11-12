A = [1,2,3]
B = [1,3,6,4,1,2]
C = [-1,-4]

def getSmal(a):
    for n in range(1,1000):
        if n not in a:
            return n

print(getSmal(A))
print(getSmal(B))
print(getSmal(C))