function [y1, y2]=cross_over_process(x1,x2,minval1,maxval1,minval2,maxval2)

    alpha=rand(size(x1));
    
    y1=alpha.*x1+(1-alpha).*x2;
    y2=alpha.*x2+(1-alpha).*x1;
    
    tmbv=round(y1(1:4));
    val=unique(tmbv);
    for k3=1:length(val)
        logh=find(tmbv==val(k3));
        if(length(logh)~=1)
           tmbv(logh(1))=tmbv(logh(1))+1;
        end
    end
    y1(1:4)=tmbv;
    
    tmbv=round(y2(1:4));
    val=unique(tmbv);
    for k3=1:length(val)
        logh=find(tmbv==val(k3));
        if(length(logh)~=1)
           tmbv(logh(1))=tmbv(logh(1))+1;
        end
    end
    y2(1:4)=tmbv;
    
        
    
    
    y1=[round(y1(1:4)) y1(5:end)];
    y2=[round(y2(1:4)) y2(5:end)];
    
    
    for k1=1:4
        
         if(y1(k1)<minval1)
            y1(k1)=minval1;
         end
         if(y2(k1)<minval1)
            y2(k1)=minval1;
         end
         
        if(y1(k1)>maxval1)
            y1(k1)=maxval1;
         end
         if(y2(k1)>maxval1)
            y2(k1)=maxval1;
         end

      
        
    end
    
    for k1=5:8
        
         if(y1(k1)<minval2)
            y1(k1)=minval2;
         end
         if(y2(k1)<minval2)
            y2(k1)=minval2;
         end
         
        if(y1(k1)>maxval2)
            y1(k1)=maxval2;
         end
         if(y2(k1)>maxval2)
            y2(k1)=maxval2;
         end

      
        
    end
    
    
    
    
    
    
    
    
    
    
    
    
end





