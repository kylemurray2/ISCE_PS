function [dn,searchresults,sortdn,sortresults]=I_subset(r,dn,searchresults,sortdn,sortresults)

dn(max(r)+1:end)=[];
searchresults(max(r)+1:end)=[];
sortresults(max(r)+1:end)=[];
sortdn(max(r)+1:end)=[];

if min(r)>1
    dn(1:min(r)-1)=[];
    searchresults(1:min(r)-1)=[];
    sortresults(1:min(r)-1)=[];
    sortdn(1:min(r)-1)=[];
end
