function  ACTIVE_LOSS=flow_cal(nb,V,del,BMva)

[Y aval]=abmitt_imp_bus(nb);                
lined=bus_line_data(nb);          
busd=bus_data_val(nb);            
Vm=pol2rect(V,del);          
         
fb = lined(:,1);                
tb = lined(:,2);                
nl = length(fb);                
Pl = busd(:,7);                 
Ql = busd(:,8);                 

Iij = zeros(nb,nb);
Sij = zeros(nb,nb);
Si = zeros(nb,1);


I = Y*Vm;
Im = abs(I);
Ia = angle(I);
 

for m = 1:nl
    p = fb(m); q = tb(m);
    Iij(p,q) = -(Vm(p) - Vm(q))*Y(p,q);
    Iij(q,p) = -Iij(p,q);
end
Iij = sparse(Iij);
Iijm = abs(Iij);
Iija = angle(Iij);


for m = 1:nb
    for n = 1:nb
        if m ~= n
            Sij(m,n) = Vm(m)*conj(Iij(m,n))*BMva;
        end
    end
end

fdata=Sij;

Sij = sparse(Sij);
Pij = real(Sij);
Qij = imag(Sij);
 


Lij = zeros(nl,1);
for m = 1:nl
    p = fb(m); q = tb(m);
    Lij(m) = Sij(p,q) + Sij(q,p);
end


Lpij = real(Lij);
Lqij = imag(Lij);

po_val=(Lqij);

ACTIVE_LOSS=sum(Lpij);
REACTIVE_LOSS=sum(Lqij);



loss_var=aval;

for i = 1:nb
    for k = 1:nb
        Si(i) = Si(i) + conj(Vm(i))* Vm(k)*Y(i,k)*BMva;
    end
end
Pi = real(Si);
Qi = -imag(Si);
Pg = abs(Pi+Pl);
Qg = abs(Qi+Ql);
 

act_loss=Pg;
ract_loss=Qg;

    

   
