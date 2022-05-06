import json
from random import randint
source /home/ganer/Scripts/xonsh_scripts/pymods/set_context.xsh
set_context(__file__)

# By far the most esoteric code I've written lol 
m, find, check, mx = λ(ω(x[1]) if type(x)==tuple else x)(λ(λ(((a.ℚ(*np,t:=t+1),ω(a=a,l=np,c=c-1,t=t)) if (a.len()>(np:=(λt(x+y)(l,((-1,0),(0,1),(1,0),(0,-1))[randint(0,3)])))[0]>=0 and a.len()>np[1]>=0 and a.ℝ(*np)==0) else ω(a=a,l=l,c=c-1,t=t)) if c>0 else a,l=λt(i//2)(2,i=x.len()),a=x,t=0,c=300)())(m:=λt(λt(0)(0 .rep(v)))(0 .rep(v:=50)))), λ(Γ(λ((m.index(k := λf(i in x)(m,i=x)[0]), k.index(x)), x=x, m=m))), λ(x > 0 and y > 0 and x < v and y < v and m[y][x], v=v, m=m), max(max(m,key=λ(max(x))))

ap = {
    'U': 2,
    'R': 3,
    'D': 5,
    'L': 7
}

def g(oo=1):
    q1,q2,s=[],[],''
    x,y=find(oo)
    if oo>1 and (p:=find(oo-1)):
        if   p[0]<x: s+='U'
        elif p[0]>x: s+='D'
        elif p[1]<y: s+='L'
        elif p[1]>y: s+='R'
    if (p:=find(oo+1)):
        if   p[0]>x: s+='D'
        elif p[0]<x: s+='U'
        elif p[1]>y: s+='R'
        elif p[1]<y: s+='L'
    s = sorted(list(set(s)))
    q1 += [s.cat()]
    q2 += [ap[s[0]] * (ap[s[1]] if len(s)>1 else 1)]
    if oo < mx:
        j = g(oo + 1)
        q1 += j[0]
        q2 += j[1]
        return q1, q2
    else:
        return q1, q2

print(λt((λt(f'{{:^{i}}}'.format(x) if x>0 else ' '*i)(x,i=2)).cat('·'))(m).cat('\n'))

bruh=[]
s = g()
m2 = λt(x.copy())(m)
def b(oo=1, primes=s):
    global bruh
    x,y=find(oo)
    bruh += [(x,y)]
    m2[x][y] = primes[1][oo-1]
    if oo < primes[1].len():
        b(oo+1, primes)

b()
m = m2

print(λt(f"{x+1}-{y}")(*zip(*list(enumerate(s[0])))).cat(' 🠒 '))
print(λt((λt(f'{{:^{i}}}'.format(x) if x>0 else ' '*i)(x,i=2)).cat('·'))(m).cat('\n'))

with open("./data/path.txt", 'w') as f:
    f.write(json.dumps({
        'size': v,
        'grid': m,
        'directions': s[0],
        'coprimes': s[1],
        'coords': bruh
    }))

![java -jar processing-py.jar "/home/ganer/Projects/Simulations+Visualizations/Raymarching/rails/engine.pyde"]