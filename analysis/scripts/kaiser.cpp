#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
double kaiser(IntegerMatrix A) {
  int n_count = A.nrow();
  std::vector<double> w(n_count);
  int n_neigh = 0;
  for(int i = 0; i < n_count; i++) {
    IntegerVector row = A.row(i);
    IntegerVector col = A.column(i);
    // Sum both vectors
    std::transform(row.begin(), row.end(), col.begin(), row.begin(), std::plus<int>());
    // Define indices of non-zero elements
    std::vector<int> n;
    for(int k = 0; k < row.size(); k++) {
      if(row[k] != 0) {
        n.push_back(k);
      }
    }
    // Sort vector n
    sort(n.begin(), n.end());
    // Identify unique elements in vector n
    std::vector<int>::iterator it;
    it = unique(n.begin(), n.end());
    n.resize(distance(n.begin(), it));
    int n_e = 0;
    int l_n = n.size();
    for(int j = 0; j < l_n; j++) {
      IntegerVector vec = A.row(n[j]);
      // Define indices of non-zero elements
      std::vector<int> n_v;
      for(int l = 0; l < vec.size(); l++) {
        if(vec[l] != 0) {
          n_v.push_back(l);
        }
      }
      // Sort vectors n and n_v
      //std::sort(n.begin(), n.end());
      std::sort(n_v.begin(), n_v.end());
      // Identify unique elements in vector n_v
      std::vector<int>::iterator it;
      it = unique(n_v.begin(), n_v.end());  
      n_v.resize(distance(n_v.begin(),it));
      // Union of n and n_v
      std::vector<int> uni;
      set_union(n.begin(), n.end(), n_v.begin(), n_v.end(), back_inserter(uni));
      n_e = n_e + l_n + n_v.size() - uni.size();
    }
    if(l_n > 1) {
      w.at(i) =  (double)n_e / (l_n * (l_n - 1));
      n_neigh++ ;
    }
  }
  double s = std::accumulate(w.begin(), w.end(), 0.0);
  double cl = s / n_neigh;
  return(cl);
}