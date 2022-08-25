function [data_func_in, F]=non_dominate_sorting_process(data_func_in)

    nPop=numel(data_func_in);

    for i=1:nPop
        data_func_in(i).DominationSet=[];
        data_func_in(i).DominatedCount=0;
    end
    
    F{1}=[];
    
    for i=1:nPop
        for j=i+1:nPop
            p=data_func_in(i);
            q=data_func_in(j);
            
            if dominate_process(p,q)
                p.DominationSet=[p.DominationSet j];
                q.DominatedCount=q.DominatedCount+1;
            end
            
            if dominate_process(q.Cost,p.Cost)
                q.DominationSet=[q.DominationSet i];
                p.DominatedCount=p.DominatedCount+1;
            end
            
            data_func_in(i)=p;
            data_func_in(j)=q;
        end
        
        if data_func_in(i).DominatedCount==0
            F{1}=[F{1} i];
            data_func_in(i).Rank=1;
        end
    end
    
    k=1;
    
    while true
        
        Q=[];
        
        for i=F{k}
            p=data_func_in(i);
            
            for j=p.DominationSet
                q=data_func_in(j);
                
                q.DominatedCount=q.DominatedCount-1;
                
                if q.DominatedCount==0
                    Q=[Q j]; %#ok
                    q.Rank=k+1;
                end
                
                data_func_in(j)=q;
            end
        end
        
        if isempty(Q)
            break;
        end
        
        F{k+1}=Q; 
        
        k=k+1;
        
    end
    

end