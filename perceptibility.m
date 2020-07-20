DATA.SEA = [0.422, 0.111, 0.211, 0.644, 0.144, 0.133, 0.278, 0.733, 0.144, 0.378];
DATA.WALK = [0.489, 0.167, 0.322, 0.233, 0.333, 0.578, 0.167, 0.2, 0.189, 0.622];
DATA.FLOWER = [0.167, 0.2, 0.144, 0.2, 0.156, 0.133, 0.211, 0.189, 0.156, 0.156];
DATA.BIRDS = [0.122, 0.478, 0.067, 0.178, 0.467, 0.133, 0.089, 0.2, 0.522, 0.133];

ORIGINAL.SEA = DATA.SEA(6);
ORIGINAL.BIRDS = DATA.BIRDS(7);
ORIGINAL.WALK = DATA.WALK(8);
ORIGINAL.FLOWER = DATA.FLOWER(9);

INDEX.SEA = 6;
INDEX.BIRDS = 7;
INDEX.WALK = 8;
INDEX.FLOWER = 9;

n1 = 90;
n2 = 90;

N = 90;
video = {'SEA','WALK','FLOWER','BIRDS'};

for video_ = video
    video__ = video_{1};
    
    pcode = DATA.(video__);
    porig = ORIGINAL.(video__);
    
    p = (pcode*n1 + porig*n2)/(n1+n2);
    
    Z = abs((porig - pcode)./sqrt(p.*(1 - p)*(1/n1 + 1/n2)));
    
    df = 90 - 2;
    
    fprintf('p-values for %s (discard the %d-th element) \n',video__, INDEX.(video__));
    2*tcdf(Z,df,'upper')
end