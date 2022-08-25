function y=mutation_process(x,mu,sigma,minval1,maxval1,minval2,maxval2)

    nVar=numel(x);
    
    nMu=ceil(mu*nVar);

    j=randsample(nVar,nMu);
    if numel(sigma)>1
        sigma = sigma(j);
    end
    
    y=x;
    
    y(j)=x(j)+sigma.*randn(size(j));

     y=[round(y(1:4)) y(5:end)];
     y1=y;
     
     tmbv=round(y1(1:4));
    val=unique(tmbv);
    for k3=1:length(val)
        logh=find(tmbv==val(k3));
        if(length(logh)~=1)
           tmbv(logh(1))=tmbv(logh(1))+1;
        end
    end
    y1(1:4)=tmbv;

    
     for k1=1:4
        
         if(y1(k1)<minval1)
            y1(k1)=minval1;
         end
         
        if(y1(k1)>maxval1)
            y1(k1)=maxval1;
         end
             
        
    end
    
    for k1=5:8
        
         if(y1(k1)<minval2)
            y1(k1)=minval2;
         end
         if(y1(k1)>maxval2)
            y1(k1)=maxval2;
         end
              
    end
    
    y=y1;
    
end






