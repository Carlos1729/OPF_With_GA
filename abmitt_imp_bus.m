function [Y a]=abmitt_imp_bus(num)  

linedata =bus_line_data(num);


fb = linedata(:,1);            
tb = linedata(:,2);            
r = linedata(:,3);             
x = linedata(:,4);             
b = linedata(:,5);             
a = linedata(:,6);             
z = r + i*x;                   
y = 1./z;                      
b = i*b;                       

nb = max(max(fb),max(tb));     
nl = length(fb);               
Y = zeros(nb,nb);              
 

 for k = 1:nl
     Y(fb(k),tb(k)) = Y(fb(k),tb(k)) - y(k)/a(k);
     Y(tb(k),fb(k)) = Y(fb(k),tb(k));
 end
 

 for m = 1:nb
     for n = 1:nl
         if fb(n) == m
             Y(m,m) = Y(m,m) + y(n)/(a(n)^2) + b(n);
         elseif tb(n) == m
             Y(m,m) = Y(m,m) + y(n) + b(n);
         end
     end
 end
