function fout=feed_power(nbus,datain)


Y =abmitt_imp_bus(nbus);
busd =bus_data_val(nbus);
BMva = 100;
bus = busd(:,1);
type = busd(:,2);
V = busd(:,3);
del = busd(:,4);
Pg = busd(:,5)/BMva;
Qg = busd(:,6)/BMva;
Pl = busd(:,7)/BMva;
Ql = busd(:,8)/BMva;
Qmin = busd(:,9)/BMva;
Qmax = busd(:,10)/BMva;
P = Pg - Pl;
Q = Qg - Ql;
Psp = P;
Qsp = Q;
G=real(Y);
B=imag(Y);


node_loc=datain(1:4);
size_val=datain(5:8);

for k3=1:length(node_loc)
    Psp(node_loc(k3))=Psp(node_loc(k3))+size_val(k3);
    Qsp(node_loc(k3))=Qsp(node_loc(k3))+size_val(k3);
    
end






pv = find(type == 2 | type == 1);
pq = find(type == 3);
npv = length(pv);
npq = length(pq);



        
P = zeros(nbus,1);
Q = zeros(nbus,1);


% for i = 1:nbus
%     for k = 1:nbus
%         P(i) = P(i) + V(i)* V(k)*(G(i,k)*cos(del(i)-del(k)) + B(i,k)*sin(del(i)-del(k)));
%         Q(i) = Q(i) + V(i)* V(k)*(G(i,k)*sin(del(i)-del(k)) - B(i,k)*cos(del(i)-del(k)));
%     end
% end

%-----
for i = 1:nbus
%     if i == 3 || 8
%         P(i) = 0;
%         Q(i) = 0;
%     else
    for k = 1:nbus
        P(i) = P(i) + V(i)* V(k)*(G(i,k)*cos(del(i)-del(k)) + B(i,k)*sin(del(i)-del(k)));
        Q(i) = Q(i) + V(i)* V(k)*(G(i,k)*sin(del(i)-del(k)) - B(i,k)*cos(del(i)-del(k)));
    end
%     end
end
%-----



for n = 2:nbus
    if type(n) == 2
        QG = Q(n)+Ql(n);
        if QG < Qmin(n)
            V(n) = V(n) + 0.01;
        elseif QG > Qmax(n)
            V(n) = V(n) - 0.01;
        end
    end
end



dPa = Psp-P;
dQa = Qsp-Q;
k = 1;
dQ = zeros(npq,1);
for i = 1:nbus
    if type(i) == 3
        dQ(k,1) = dQa(i);
        k = k+1;
    end
end
dP = dPa(2:nbus);
M = [dP; dQ];


jpt = zeros(nbus-1,nbus-1);
for i = 1:(nbus-1)
    m = i+1;
    for k = 1:(nbus-1)
        n = k+1;
        if n == m
            for n = 1:nbus
                jpt(i,k) = jpt(i,k) + V(m)* V(n)*(-G(m,n)*sin(del(m)-del(n)) + B(m,n)*cos(del(m)-del(n)));
            end
            jpt(i,k) = jpt(i,k) - V(m)^2*B(m,m);
        else
            jpt(i,k) = V(m)* V(n)*(G(m,n)*sin(del(m)-del(n)) - B(m,n)*cos(del(m)-del(n)));
        end
    end
end


jpv = zeros(nbus-1,npq);
for i = 1:(nbus-1)
    m = i+1;
    for k = 1:npq
        n = pq(k);
        if n == m
            for n = 1:nbus
                jpv(i,k) = jpv(i,k) + V(n)*(G(m,n)*cos(del(m)-del(n)) + B(m,n)*sin(del(m)-del(n)));
            end
            jpv(i,k) = jpv(i,k) + V(m)*G(m,m);
        else
            jpv(i,k) = V(m)*(G(m,n)*cos(del(m)-del(n)) + B(m,n)*sin(del(m)-del(n)));
        end
    end
end

jqt = zeros(npq,nbus-1);
for i = 1:npq
    m = pq(i);
    for k = 1:(nbus-1)
        n = k+1;
        if n == m
            for n = 1:nbus
                jqt(i,k) = jqt(i,k) + V(m)* V(n)*(G(m,n)*cos(del(m)-del(n)) + B(m,n)*sin(del(m)-del(n)));
            end
            jqt(i,k) = jqt(i,k) - V(m)^2*G(m,m);
        else
            jqt(i,k) = V(m)* V(n)*(-G(m,n)*cos(del(m)-del(n)) - B(m,n)*sin(del(m)-del(n)));
        end
    end
end


jqv = zeros(npq,npq);
for i = 1:npq
    m = pq(i);
    for k = 1:npq
        n = pq(k);
        if n == m
            for n = 1:nbus
                jqv(i,k) = jqv(i,k) + V(n)*(G(m,n)*sin(del(m)-del(n)) - B(m,n)*cos(del(m)-del(n)));
            end
            jqv(i,k) = jqv(i,k) - V(m)*B(m,m);
        else
            jqv(i,k) = V(m)*(G(m,n)*sin(del(m)-del(n)) - B(m,n)*cos(del(m)-del(n)));
        end
    end
end
JR=jqv-jqt*(inv(jpt))*jpv;
J=[jpt jpv; jqt jqv];
X = (inv(J))*M;
dTh = X(1:nbus-1);
dV = X(nbus:end);
[e1,d1,n1]=eig(JR);
f2val=max(1./diag((d1)))*max(abs(dQ));
del(2:nbus) = dTh + del(2:nbus);
k = 1;
for i = 2:nbus
    if type(i) == 3
        V(i) = dV(k) + V(i);
        k = k+1;
    end
end
tval=sum(1./diag((d1)));
po_val=flow_cal(nbus,V,del,BMva);
f1val=sum(po_val);
f3val=sum(datain(5:8));

fout=[f1val; f2val; f3val];

POWER_LOSSES=po_val;
STABILITY_INDEX=tval;

save resg.mat POWER_LOSSES STABILITY_INDEX V d1







