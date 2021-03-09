#include "mex.hpp"
#include "mexAdapter.hpp"

#include <vector>
#include <algorithm>
#include <deque>

#define INF (0x3f3f3f3f)

using namespace std;
using matlab::mex::ArgumentList;

class MexFunction : public matlab::mex::Function {
public:
    void operator()(ArgumentList outputs, ArgumentList inputs) {
        const int nodes = inputs[ 0 ][ 0 ];
        vector<vector<int>> dist(nodes, vector<int>(nodes));
        for (int i = 0; i < nodes; i++) {
            for (int j = 0; j < nodes; j++) {
                dist[ i ][ j ] = inputs[ 1 ][ i ][ j ];
            }
        }
        
        const vector<int> answer = compute_matching(nodes, dist);
        
        matlab::data::ArrayFactory factory;
        outputs[0] = factory.createArray<int32_t>({ 1, answer.size() }, answer.data(), answer.data() + answer.size());
            
       
    }
    
    inline int bellmanford(int n, vector<vector<int>> &G, vector<vector<int>> &capacity, vector<vector<int>> &cost, vector<vector<int>> &flow) {
      deque <int> q;
      vector<bool>inq(n);
      vector<int> dad(n);
      vector<int> dist(n);

      int node, minflow, source = 0, sink = n - 1;

      for (int i = 0; i < n; i++) {
        dist[ i ] = INF;
      }

      dist[source] = 0;
      q.push_back(source);
      inq[source] = true;

      while (!q.empty()) {
        node = q.front();
        q.pop_front();
        inq[node] = false;
        if (node == sink) continue;

        for (auto son: G[node]) {
          if (flow[node][son] < capacity[node][son] &&
              dist[node] + cost[node][son] < dist[son]) {
                dist[son] = dist[node] + cost[node][son];
                dad[son] = node;

                if (!inq[son]) {
                  inq[son] = true;
                  q.push_back(son);
                }
          }
        }
      }

      if (dist[sink] == INF)
        return 0;

      for (node = sink; node != source; node = dad[node])
        minflow = min(minflow, capacity[dad[node]][node] - flow[dad[node]][node]);

      for (node = sink; node != source; node = dad[node]) {
        flow[dad[node]][node] += minflow;
        flow[node][dad[node]] -= minflow;
      }

      return minflow;
    }

    vector<int> compute_matching(int nodes, vector<vector<int>> dist) {
      int total = nodes * 2 + 2;
      vector <vector<int>> G(total);
      vector <vector<int>> capacity(total, vector<int>(total));
      vector <vector<int>> cost(total, vector<int>(total));
      vector <vector<int>> flow(total, vector<int>(total));

      for (int i = 0; i < nodes; i++) {
        for (int j = 0; j < nodes; j++) {
          int x = i + 1, y = nodes + j + 1;
          if (dist[ i ][ j ] != 0) {
            int c = dist[ i ][ j ];

            capacity[ x ][ y ] = 1;
            cost[ x ][ y ] = c;
            cost[ y ][ x ] = -c;

            G[ x ].push_back(y);
            G[ y ].push_back(x);

          }
        }
      }

      /// add source and sink

      for (int i = 1; i <= nodes; i++) {
        G[ 0 ].push_back( i );
        capacity[ 0 ][ i ] = 1;
        cost[ 0 ][ i ] = 0;
      }

      for (int i = nodes + 1; i <= 2 * nodes; i++) {
        G[ i ].push_back(2 * nodes + 1);
        capacity[ i ][2 * nodes + 1] = 1;
      }

      int maxflow = 0;
      while (int minflow = bellmanford(total, G, capacity, cost, flow))
        maxflow += minflow;

      //fout << maxflow << '\n';

      vector<int> pairs;

      for (int i = 1; i <= nodes; i++) {
        for (int j = 1; j <= nodes; j++) {
          if (flow[ i ][j + nodes] > 0) {
            pairs.push_back(j - 1);
          }
        }

      }

      return pairs;

    }
};


